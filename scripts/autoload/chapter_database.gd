extends Node

## Scans res://data/chapters/ on startup and indexes every StoryChapter
## resource by its id, ordered by `number`. Mirrors StoryDatabase's pattern.

const CHAPTERS_DIR: String = "res://data/chapters/"

var _chapters_by_id: Dictionary = {}
var _ordered: Array[StoryChapter] = []

func _ready() -> void:
	_scan_directory(CHAPTERS_DIR)
	_ordered.sort_custom(func(a: StoryChapter, b: StoryChapter) -> bool: return a.number < b.number)

func get_chapter(id: String) -> StoryChapter:
	return _chapters_by_id.get(id)

func get_all_ordered() -> Array[StoryChapter]:
	return _ordered

func _scan_directory(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("ChapterDatabase: could not open directory '%s'" % path)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		var full_path := path.path_join(file_name)
		if dir.current_is_dir():
			_scan_directory(full_path + "/")
		elif file_name.ends_with(".tres") or file_name.ends_with(".res"):
			_register_chapter(load(full_path))
		file_name = dir.get_next()
	dir.list_dir_end()

func _register_chapter(resource: Resource) -> void:
	if not (resource is StoryChapter):
		return
	if resource.id.is_empty():
		push_warning("ChapterDatabase: a chapter is missing an id, skipping.")
		return
	if _chapters_by_id.has(resource.id):
		push_warning("ChapterDatabase: duplicate chapter id '%s'." % resource.id)
	_chapters_by_id[resource.id] = resource
	_ordered.append(resource)
