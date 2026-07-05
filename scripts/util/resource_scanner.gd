class_name ResourceScanner
extends RefCounted

## Recursively scans a res:// directory for .tres/.res files and calls
## `callback` with each loaded Resource. Shared by StoryDatabase,
## ChapterDatabase, and CodexDatabase so any new content type can reuse the
## same "drop a file in a folder" authoring pattern.
static func scan_directory(path: String, callback: Callable) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("ResourceScanner: could not open directory '%s'" % path)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		var full_path := path.path_join(file_name)
		if dir.current_is_dir():
			scan_directory(full_path + "/", callback)
		elif file_name.ends_with(".tres") or file_name.ends_with(".res"):
			callback.call(load(full_path))
		file_name = dir.get_next()
	dir.list_dir_end()
