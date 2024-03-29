module template

// parse template with target
pub fn parse(template string, target map[string]string) string {
	mut content := template
	for key in target.keys() {
		at_key := '@' + key
		value := target[key]
		// assign to content
		content = content.replace(at_key, value)
	}
	return content
}
