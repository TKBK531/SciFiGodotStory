extends Node

## Scans res://data/codex_categories/ and res://data/codex/ on startup and
## indexes CodexCategory/CodexEntry resources by id. Mirrors
## StoryDatabase/ChapterDatabase's "drop a file in a folder" pattern.

const CATEGORIES_DIR: String = "res://data/codex_categories/"
const ENTRIES_DIR: String = "res://data/codex/"

var _categories_by_id: Dictionary = {}
var _categories_ordered: Array[CodexCategory] = []
var _entries_by_id: Dictionary = {}

func _ready() -> void:
	ResourceScanner.scan_directory(CATEGORIES_DIR, _register_category)
	ResourceScanner.scan_directory(ENTRIES_DIR, _register_entry)
	_categories_ordered.sort_custom(func(a: CodexCategory, b: CodexCategory) -> bool: return a.sort_order < b.sort_order)

func get_category(id: String) -> CodexCategory:
	return _categories_by_id.get(id)

func get_categories_ordered() -> Array[CodexCategory]:
	return _categories_ordered

func get_entry(id: String) -> CodexEntry:
	return _entries_by_id.get(id)

func get_entries_for_category(category_id: String) -> Array[CodexEntry]:
	var result: Array[CodexEntry] = []
	for entry in _entries_by_id.values():
		if entry.category_id == category_id:
			result.append(entry)
	return result

func _register_category(resource: Resource) -> void:
	if not (resource is CodexCategory):
		return
	if resource.id.is_empty():
		push_warning("CodexDatabase: a codex category is missing an id, skipping.")
		return
	if _categories_by_id.has(resource.id):
		push_warning("CodexDatabase: duplicate codex category id '%s'." % resource.id)
	_categories_by_id[resource.id] = resource
	_categories_ordered.append(resource)

func _register_entry(resource: Resource) -> void:
	if not (resource is CodexEntry):
		return
	if resource.id.is_empty():
		push_warning("CodexDatabase: a codex entry is missing an id, skipping.")
		return
	if _entries_by_id.has(resource.id):
		push_warning("CodexDatabase: duplicate codex entry id '%s'." % resource.id)
	_entries_by_id[resource.id] = resource
