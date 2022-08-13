module commands

import os
import cli

pub fn execute() {
	mut app := cli.Command{
		name: 'vss'
		version: '0.0.7'
		description: 'static site generator'
		execute: fn (cmd cli.Command) ? {
			println(cmd.help_message())
		}
	}

	app.add_command(new_build_cmd())

	app.setup()
	app.parse(os.args)
}