module process

struct Files {
pub mut:
	base_dir string
	files []string
	dirs []string
}

fn generate_path_map(path_list []string) {}