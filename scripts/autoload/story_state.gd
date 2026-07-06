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

## Current value per AttributeDefinition/FactionDefinition id, seeded from
## each definition's starting_value on reset().
var attributes: Dictionary = {}
var faction_trust: Dictionary = {}

func reset() -> void:
	flags.clear()
	history.clear()
	current_node_id = START_NODE_ID
	attributes.clear()
	for definition in AttributeDatabase.get_all_ordered():
		attributes[definition.id] = definition.starting_value
	faction_trust.clear()
	for definition in FactionDatabase.get_all_ordered():
		faction_trust[definition.id] = definition.starting_value

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

func get_attribute(id: String, default_value: float = 0.0) -> float:
	return attributes.get(id, default_value)

func get_faction_trust(id: String, default_value: float = 0.0) -> float:
	return faction_trust.get(id, default_value)

func modify_attribute(id: String, delta: float) -> void:
	var new_value: float = get_attribute(id) + delta
	var definition := AttributeDatabase.get_attribute(id)
	if definition != null:
		new_value = clamp(new_value, definition.min_value, definition.max_value)
	attributes[id] = new_value

func modify_faction_trust(id: String, delta: float) -> void:
	var new_value: float = get_faction_trust(id) + delta
	var definition := FactionDatabase.get_faction(id)
	if definition != null:
		new_value = clamp(new_value, definition.min_value, definition.max_value)
	faction_trust[id] = new_value

## True only if every attribute in required_values is at or above the
## required minimum - unlike meets_requirements, this is a threshold check,
## not an exact match.
func meets_min_attributes(required_values: Dictionary) -> bool:
	return _meets_minimums(required_values, attributes)

func meets_min_faction_trust(required_values: Dictionary) -> bool:
	return _meets_minimums(required_values, faction_trust)

func _meets_minimums(required_values: Dictionary, current_values: Dictionary) -> bool:
	for key in required_values:
		if current_values.get(key, 0.0) < required_values[key]:
			return false
	return true

func goto_node(node_id: String) -> void:
	current_node_id = node_id
	history.append(node_id)
	node_changed.emit(node_id)
