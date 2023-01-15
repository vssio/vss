module commands

import os
import cli

// execute is the root function of the commands module
pub fn execute() {
	mut app := cli.Command{
		name: 'vss'
		version: '0.1.0'
		description: 'static site generator'
		execute: fn (cmd cli.Command) ! {
			println(cmd.help_message())
		}
	}

	app.add_command(new_build_cmd())
	app.add_command(new_serve_cmd())

	app.setup()
	app.parse(os.args)
}

