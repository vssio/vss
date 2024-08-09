module main

import os
import cli
import log
import commands
import internal.config

const version = '0.3.1'

const default_config = 'config.toml'

// load_config loads a toml config file
fn load_config(toml_file string) !config.Config {
	toml_text := os.read_file(toml_file)!
	return config.load(toml_text)
}

fn init_logger() &log.Log {
	mut l := log.Log{}
	l.set_level(.info)
	return &l
}

fn init_commands() cli.Command {
	return cli.Command{
		name: 'vss'
		version: version
		description: 'static site generator'
		execute: fn (cmd cli.Command) ! {
			println(cmd.help_message())
		}
		commands: [
			cli.Command{
				name: 'build'
				description: 'build your site'
				usage: 'vss build'
				execute: fn (cmd cli.Command) ! {
					mut logger := init_logger()
					conf := load_config(default_config)!
					mut c := commands.new_build_cmd(conf, logger)
					c.run() or {
						logger.error(err.msg())
						println('build failed')
					}
				}
			},
			cli.Command{
				name: 'serve'
				description: 'serve dist'
				usage: 'vss serve'
				execute: fn (cmd cli.Command) ! {
					mut logger := init_logger()
					conf := load_config(default_config)!
					mut c := commands.new_serve_cmd(conf, logger)
					c.run() or {
						logger.error(err.msg())
						println('serve failed')
					}
				}
			},
		]
	}
}

fn main() {
	mut app := init_commands()
	app.setup()
	app.parse(os.args)
}
