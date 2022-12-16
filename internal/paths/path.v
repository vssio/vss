module paths

import os

struct Files {
pub mut:
	base_dir string
	files    []string
	dirs     []string
}

fn generate_path_map(path_list []string) {}

pub fn get_html_path(md_path string) string {
	mut file_name := os.file_name(md_path)
	file_name = file_name.replace('.md', '.html')
	dir := os.dir(md_path)
	if dir == '.' {
		return file_name
	}

	return os.join_path(dir, file_name)
}

pub fn normalise_paths(paths []string) []string {
	cwd := os.getwd() + os.path_separator
	mut res := paths.map(os.abs_path(it).replace(cwd, '').replace(os.path_separator, '/'))
	// sort the array in decending order
	res.sort(a > b)
	return res
}
