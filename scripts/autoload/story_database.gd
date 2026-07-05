extends Node

## Scans res://data/story/ on startup and indexes every StoryNode resource by
## its id. Drop new .tres files into that folder (or subfolders, e.g. one per
## chapter) and they become available automatically - no code changes needed.

const STORY_DIR: String = "res://data/story/"

var _nodes_by_id: Dictionary = {}

func _ready() -> void:
	ResourceScanner.scan_directory(STORY_DIR, _register_node)

func get_node_by_id(id: String) -> StoryNode:
	return _nodes_by_id.get(id)

func has_node_id(id: String) -> bool:
	return _nodes_by_id.has(id)

func _register_node(resource: Resource) -> void:
	if not (resource is StoryNode):
		return
	if resource.id.is_empty():
		push_warning("StoryDatabase: a story node is missing an id, skipping.")
		return
	if _nodes_by_id.has(resource.id):
		push_warning("StoryDatabase: duplicate story node id '%s'." % resource.id)
	_nodes_by_id[resource.id] = resource
