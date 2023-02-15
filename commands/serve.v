module commands

import cli
import log
import net.http
import os
import internal.config

const cport = 8080

fn new_serve_cmd() cli.Command {
	return cli.Command{
		name: 'serve'
		description: 'serve dist'
		usage: 'vss serve'
		execute: fn (cmd cli.Command) ! {
			mut logger := log.Log{}
			logger.set_level(log.Level.info)
			serve(mut logger) or {
				logger.error(err.msg())
				println('serve failed')
			}
		}
	}
}

struct MyHttpHandler {
mut:
	root string
}

fn normalise_path(path string) string {
	cwd := os.getwd() + os.path_separator
	mut res := os.abs_path(path).replace(cwd, '').replace(os.path_separator, '/')
	return res
}

fn (mut handler MyHttpHandler) handle(req http.Request) http.Response {
	mut r := http.Response{
		header: req.header
	}

	// コンテンツを返すための処理
	wd := os.getwd()
	os_spec_path := req.url.replace('/', os.path_separator)
	mut file := wd + os.path_separator + handler.root + os_spec_path

	if os.is_dir(file) {
		file = file + os.path_separator + 'index.html'
	} else {
		if !os.is_file(file) {
			file = file + '.html'
		}
	}

	html := os.read_file(file) or {
		eprintln(err)
		r.set_status(.not_found)
		r.body = 'Not Found'
		r.set_version(req.version)
		return r
	}

	r.body = html
	r.set_status(.ok)
	r.set_version(req.version)
	return r
}

struct Watcher {
	path string
mut:
	time_stamp i64
}

fn watch(path string, config config.Config, mut logger log.Log) {
	mut res := []string{}
	os.walk_with_context(path, &res, fn (mut res []string, fpath string) {
		res << fpath
	})

	mut watchers := []Watcher{}
	for p in res {
		mut w := Watcher{
			path: p
			time_stamp: os.file_last_mod_unix(p)
		}
		watchers << w
	}

	ignore := '.' + os.path_separator + 'dist'
	for {
		for mut w in watchers {
			if w.path.starts_with(ignore) {
				continue
			}
			now := os.file_last_mod_unix(w.path)
			if now > w.time_stamp {
				println('modified file: ${w.path}')
				w.time_stamp = now

				build(config, mut logger) or {
					logger.error(err.msg())
					println('Build failed')
				}
			}
		}
	}
}

fn serve(mut logger log.Log) ! {
	mut handler := MyHttpHandler{
		root: 'dist'
	}
	mut server := &http.Server{
		handler: handler
		port: commands.cport
	}

	local_base_url := 'http://localhost:${commands.cport}/'
	mut config := load_config(default_config)!
	config.base_url = local_base_url
	println(local_base_url)

	// build before server startup
	build(config, mut logger) or {
		logger.error(err.msg())
		println('Build failed')
	}

	w := spawn watch('.', config, mut logger)
	server.listen_and_serve()

	w.wait()
}
