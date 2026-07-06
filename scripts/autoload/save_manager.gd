extends Node

## Persists StoryState to disk as JSON across MAX_SLOTS independent save
## slots. Saving to an occupied slot overwrites it - the UI layer is
## responsible for confirming that with the player first.

const SAVE_DIR: String = "user://saves"
const SAVE_EXTENSION: String = ".json"
const MAX_SLOTS: int = 10

func save_game(slot: int = 1) -> bool:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var save_data := {
		"current_node_id": StoryState.current_node_id,
		"flags": StoryState.flags,
		"history": StoryState.history,
		"attributes": StoryState.attributes,
		"faction_trust": StoryState.faction_trust,
		"timestamp": Time.get_datetime_string_from_system(),
	}
	var file := FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open save file for writing.")
		return false
	file.store_string(JSON.stringify(save_data, "\t"))
	return true

func load_game(slot: int = 1) -> bool:
	var save_data := peek_slot(slot)
	if save_data.is_empty():
		return false
	StoryState.flags = save_data.get("flags", {})
	StoryState.current_node_id = save_data.get("current_node_id", StoryState.START_NODE_ID)
	StoryState.attributes = save_data.get("attributes", {})
	StoryState.faction_trust = save_data.get("faction_trust", {})
	StoryState.history.clear()
	var loaded_history: Array = save_data.get("history", [])
	for node_id in loaded_history:
		StoryState.history.append(node_id)
	return true

func has_save(slot: int = 1) -> bool:
	return FileAccess.file_exists(_slot_path(slot))

## True if at least one of the MAX_SLOTS slots has a save in it.
func has_any_save() -> bool:
	for slot in range(1, MAX_SLOTS + 1):
		if has_save(slot):
			return true
	return false

## Slot number with the most recent timestamp, or -1 if no slot has a save.
func get_latest_slot() -> int:
	var latest_slot := -1
	var latest_timestamp := ""
	for slot in range(1, MAX_SLOTS + 1):
		var info := peek_slot(slot)
		if info.is_empty():
			continue
		var timestamp: String = info.get("timestamp", "")
		if timestamp > latest_timestamp:
			latest_timestamp = timestamp
			latest_slot = slot
	return latest_slot

func delete_save(slot: int = 1) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(_slot_path(slot))

## Reads a slot's raw save data without touching StoryState - used by the UI
## to show slot previews (timestamp, etc). Returns {} if empty/corrupted.
func peek_slot(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}
	var file := FileAccess.open(_slot_path(slot), FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {}
	return parsed

func _slot_path(slot: int) -> String:
	return SAVE_DIR.path_join("slot_%d%s" % [slot, SAVE_EXTENSION])
