module commands

import os
import cli
import log
import strings
import time
import regex
import markdown
import internal.template
import internal.config

const default_config = 'config.toml'

const default_template = 'layouts/index.html'

const defautl_static = 'static'

const default_index = 'index.md'

const default_dist = 'dist'

struct Builder {
mut:
	config           config.Config
	logger           log.Log
	dist             string
	static_dir       string
	template_content string
	config_map       map[string]string
}

fn new_builder(logger log.Log) Builder {
	return Builder{
		logger: logger
		dist: commands.default_dist
		static_dir: commands.defautl_static
	}
}

fn new_build_cmd() cli.Command {
	return cli.Command{
		name: 'build'
		description: 'build your site'
		usage: 'vss build'
		execute: fn (cmd cli.Command) ! {
			mut logger := log.Log{}
			logger.set_level(log.Level.info)
			config := load_config(commands.default_config)!
			build(config, mut logger) or {
				logger.error(err.msg())
				println('Build failed')
			}
		}
	}
}

fn get_html_path(md_path string) string {
	mut file_name := os.file_name(md_path)
	file_name = file_name.replace('.md', '.html')
	dir := os.dir(md_path)
	if dir == '.' {
		return file_name
	}

	return os.join_path(dir, file_name)
}

fn normalise_paths(paths []string) []string {
	cwd := os.getwd() + os.path_separator
	mut res := paths.map(os.abs_path(it).replace(cwd, '').replace(os.path_separator, '/'))
	// sort the array in decending order
	res.sort(a > b)
	return res
}

// pre_proc_md_to_html convert markdown relative links to html relative links
fn pre_proc_md_to_html(contents string) !string {
	lines := contents.split_into_lines()
	mut parsed_lines := []string{len: lines.len}
	mut re := regex.regex_opt(r'\[.+\]\(.+\.md\)') or { return err }

	for i, line in contents.split_into_lines() {
		start, end := re.find(line)
		if start >= 0 && end > start {
			parsed_lines[i] = line.replace('.md', '.html')
		} else {
			parsed_lines[i] = line
		}
	}
	return parsed_lines.join('\n')
}

fn get_md_content(path string) !string {
	md := os.read_file(path)!
	return pre_proc_md_to_html(md)
}

fn get_content(path string) !string {
	md := get_md_content(path)!
	return markdown.to_html(md)
}

fn (mut b Builder) md2html(md_path string) ! {
	// get html body content from md
	content := get_content(md_path)!
	// want to change from contents to content
	b.config_map['contents'] = content
	html := template.parse(b.template_content, b.config_map)
	html_path := get_html_path(md_path)
	dist_path := os.join_path(b.dist, html_path)
	if !os.exists(os.dir(dist_path)) {
		os.mkdir_all(os.dir(dist_path))!
	}
	os.write_file(dist_path, html)!
}

// load_config loads a toml config file
fn load_config(toml_file string) !config.Config {
	toml_text := os.read_file(toml_file)!
	return config.load(toml_text)
}

// copy_static copy static files to dist
fn (b Builder) copy_static() ! {
	if os.exists(b.static_dir) {
		os.cp_all(b.static_dir, b.dist, false)!
	}
}

// create_dist_dir create build output destination
fn (mut b Builder) create_dist_dir() ! {
	if os.exists(b.dist) {
		b.logger.info('re-create dist dir')
		os.rmdir_all(b.dist)!
		os.mkdir_all(b.dist)!
	} else {
		b.logger.info('create dist dir')
		os.mkdir_all(b.dist)!
	}
}

fn (mut b Builder) is_ignore(path string) bool {
	// e.g. README.md
	file_name := os.file_name(path)
	// notify user that build was skipped
	if file_name in b.config.build.ignore_files {
		return true
	}
	return false
}

fn (mut b Builder) generate_archives(mds []string) ! {
	mut buider := strings.new_builder(200)
	buider.writeln('# コンテンツ一覧')
	for path in mds {
		if b.is_ignore(path) {
			continue
		}
		buider.writeln('- [${path}](${path})')
	}
	md := buider.str()
	content := markdown.to_html(pre_proc_md_to_html(md)!)
	b.config_map['contents'] = content
	html := template.parse(b.template_content, b.config_map)
	html_path := 'archives/index.html'
	dist_path := os.join_path(b.dist, html_path)
	if !os.exists(os.dir(dist_path)) {
		os.mkdir_all(os.dir(dist_path))!
	}
	os.write_file(dist_path, html)!
}

fn build(config config.Config, mut logger log.Log) ! {
	println('Start building')
	mut sw := time.new_stopwatch()
	mut b := new_builder(logger)
	template_content := os.read_file(commands.default_template)!
	b.template_content = template_content
	b.config = config
	b.config_map = config.as_map()

	b.create_dist_dir()!
	// copy static dir files
	logger.info('copy static files')
	b.copy_static()!

	mds := normalise_paths(os.walk_ext('.', '.md'))
	logger.info('start md to html')
	b.generate_archives(mds)!
	for path in mds {
		if b.is_ignore(path) {
			logger.info('${path} is included in ignore_files, skip build')
			continue
		}
		b.md2html(path)!
	}
	logger.info('end md to html')

	sw.stop()
	println('Total in ' + sw.elapsed().milliseconds().str() + ' ms')
	return
}
