extends Node

## Scans res://data/attributes/ on startup and indexes every
## AttributeDefinition resource by its id, ordered by `sort_order`. Mirrors
## ChapterDatabase's pattern.

const ATTRIBUTES_DIR: String = "res://data/attributes/"

var _attributes_by_id: Dictionary = {}
var _ordered: Array[AttributeDefinition] = []

func _ready() -> void:
	ResourceScanner.scan_directory(ATTRIBUTES_DIR, _register_attribute)
	_ordered.sort_custom(func(a: AttributeDefinition, b: AttributeDefinition) -> bool: return a.sort_order < b.sort_order)

func get_attribute(id: String) -> AttributeDefinition:
	return _attributes_by_id.get(id)

func get_all_ordered() -> Array[AttributeDefinition]:
	return _ordered

func _register_attribute(resource: Resource) -> void:
	if not (resource is AttributeDefinition):
		return
	if resource.id.is_empty():
		push_warning("AttributeDatabase: an attribute is missing an id, skipping.")
		return
	if _attributes_by_id.has(resource.id):
		push_warning("AttributeDatabase: duplicate attribute id '%s'." % resource.id)
	_attributes_by_id[resource.id] = resource
	_ordered.append(resource)
