module config

import toml

// template_params list of field names to convert as_map
const template_params = ['title', 'description', 'base_url']

// Build settings for build
struct Build {
pub mut:
	ignore_files []string
}

// Config general settings for vss
pub struct Config {
pub mut:
	build       Build
	title       string
	description string
	base_url    string
}

// load parses settings described in toml
pub fn load(toml_text string) !Config {
	doc := toml.parse_text(toml_text)!

	mut config := doc.reflect[Config]()
	config.build = doc.value('build').reflect[Build]()

	return config
}

// as_map for template.parse
pub fn (c Config) as_map() map[string]string {
	mut mp := map[string]string{}
	mp['title'] = c.title
	mp['description'] = c.description
	mp['base_url'] = c.base_url
	return mp
}
