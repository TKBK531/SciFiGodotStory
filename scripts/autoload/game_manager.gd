extends Node

## Owns scene flow (menu <-> gameplay) and the paused/unpaused game state.
## UI scenes call these instead of touching get_tree() or SceneTree.paused
## directly, so pause/scene-change behavior stays consistent everywhere.

signal game_paused
signal game_resumed

const MAIN_MENU_SCENE: String = "res://scenes/main_menu/main_menu.tscn"
const GAMEPLAY_SCENE: String = "res://scenes/gameplay/gameplay.tscn"
const LOAD_GAME_SCENE: String = "res://scenes/load_game/load_game.tscn"

var is_paused: bool = false

func start_new_game() -> void:
	StoryState.reset()
	_change_scene(GAMEPLAY_SCENE)

func continue_game(slot: int = 1) -> bool:
	if not SaveManager.load_game(slot):
		return false
	_change_scene(GAMEPLAY_SCENE)
	return true

## Loads whichever slot was saved most recently, across all slots.
func continue_latest_game() -> bool:
	var slot := SaveManager.get_latest_slot()
	if slot == -1:
		return false
	return continue_game(slot)

func open_load_game_screen() -> void:
	_change_scene(LOAD_GAME_SCENE)

func return_to_main_menu() -> void:
	_change_scene(MAIN_MENU_SCENE)

func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	if is_paused:
		return
	is_paused = true
	get_tree().paused = true
	game_paused.emit()

func resume_game() -> void:
	if not is_paused:
		return
	is_paused = false
	get_tree().paused = false
	game_resumed.emit()

func quit_game() -> void:
	get_tree().quit()

func _change_scene(path: String) -> void:
	is_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
