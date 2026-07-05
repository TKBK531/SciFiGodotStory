extends Node

## Global story progress: which node the player is on, and every flag/variable
## the story has set so far. This is the single source of truth that
## SaveManager persists to disk.

signal flag_changed(flag_name: String, value: Variant)
signal node_changed(node_id: String)

const START_NODE_ID: String = "start"

var flags: Dictionary = {}
var current_node_id: String = ""
var history: Array[String] = []

func reset() -> void:
	flags.clear()
	history.clear()
	current_node_id = START_NODE_ID

func set_flag(flag_name: String, value: Variant = true) -> void:
	flags[flag_name] = value
	flag_changed.emit(flag_name, value)

func get_flag(flag_name: String, default_value: Variant = false) -> Variant:
	return flags.get(flag_name, default_value)

## True only if every key in required_flags matches the current flag state.
func meets_requirements(required_flags: Dictionary) -> bool:
	for flag_name in required_flags:
		if flags.get(flag_name) != required_flags[flag_name]:
			return false
	return true

func goto_node(node_id: String) -> void:
	current_node_id = node_id
	history.append(node_id)
	node_changed.emit(node_id)
