extends Node

## Scans res://data/factions/ on startup and indexes every FactionDefinition
## resource by its id, ordered by `sort_order`. Mirrors ChapterDatabase's
## pattern.

const FACTIONS_DIR: String = "res://data/factions/"

var _factions_by_id: Dictionary = {}
var _ordered: Array[FactionDefinition] = []

func _ready() -> void:
	ResourceScanner.scan_directory(FACTIONS_DIR, _register_faction)
	_ordered.sort_custom(func(a: FactionDefinition, b: FactionDefinition) -> bool: return a.sort_order < b.sort_order)

func get_faction(id: String) -> FactionDefinition:
	return _factions_by_id.get(id)

func get_all_ordered() -> Array[FactionDefinition]:
	return _ordered

func _register_faction(resource: Resource) -> void:
	if not (resource is FactionDefinition):
		return
	if resource.id.is_empty():
		push_warning("FactionDatabase: a faction is missing an id, skipping.")
		return
	if _factions_by_id.has(resource.id):
		push_warning("FactionDatabase: duplicate faction id '%s'." % resource.id)
	_factions_by_id[resource.id] = resource
	_ordered.append(resource)
