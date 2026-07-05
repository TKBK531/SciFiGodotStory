extends Node

## Persistent, cross-save record of every node the player has ever reached
## and every choice they've ever taken, across every slot and every New Game.
## This is what lets the Story Map show "you found this in another
## playthrough" vs "you have never seen this" - deliberately separate from
## SaveManager's per-slot save files, since it's meta-knowledge that should
## survive starting over.

const CODEX_PATH: String = "user://story_codex.json"

var visited_nodes: Dictionary = {}
var discovered_choices: Dictionary = {}
var visited_chapters: Dictionary = {}
var cleared_chapters: Dictionary = {}

func _ready() -> void:
	_load()

func record_node_visit(node: StoryNode) -> void:
	var changed := false
	if not visited_nodes.has(node.id):
		visited_nodes[node.id] = true
		changed = true
	if not node.chapter_id.is_empty() and not visited_chapters.has(node.chapter_id):
		visited_chapters[node.chapter_id] = true
		changed = true
	if node.is_chapter_end and not node.chapter_id.is_empty() and not cleared_chapters.has(node.chapter_id):
		cleared_chapters[node.chapter_id] = true
		changed = true
	if changed:
		_save()

func record_choice(from_node_id: String, to_node_id: String) -> void:
	var key := _edge_key(from_node_id, to_node_id)
	if not discovered_choices.has(key):
		discovered_choices[key] = true
		_save()

func is_node_visited(node_id: String) -> bool:
	return visited_nodes.has(node_id)

func is_choice_discovered(from_node_id: String, to_node_id: String) -> bool:
	return discovered_choices.has(_edge_key(from_node_id, to_node_id))

func is_chapter_started(chapter_id: String) -> bool:
	return visited_chapters.has(chapter_id)

func is_chapter_cleared(chapter_id: String) -> bool:
	return cleared_chapters.has(chapter_id)

func has_any_progress() -> bool:
	return not visited_nodes.is_empty()

func _edge_key(from_node_id: String, to_node_id: String) -> String:
	return "%s::%s" % [from_node_id, to_node_id]

func _save() -> void:
	var file := FileAccess.open(CODEX_PATH, FileAccess.WRITE)
	if file == null:
		push_error("StoryCodex: failed to open codex file for writing.")
		return
	var data := {
		"visited_nodes": visited_nodes,
		"discovered_choices": discovered_choices,
		"visited_chapters": visited_chapters,
		"cleared_chapters": cleared_chapters,
	}
	file.store_string(JSON.stringify(data, "\t"))

func _load() -> void:
	if not FileAccess.file_exists(CODEX_PATH):
		return
	var file := FileAccess.open(CODEX_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return
	visited_nodes = parsed.get("visited_nodes", {})
	discovered_choices = parsed.get("discovered_choices", {})
	visited_chapters = parsed.get("visited_chapters", {})
	cleared_chapters = parsed.get("cleared_chapters", {})
