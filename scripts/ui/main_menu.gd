extends Control

@onready var continue_button: Button = %ContinueButton
@onready var load_game_button: Button = %LoadGameButton
@onready var story_map_button: Button = %StoryMapButton

func _ready() -> void:
	var any_save := SaveManager.has_any_save()
	continue_button.disabled = not any_save
	load_game_button.disabled = not any_save
	story_map_button.disabled = not StoryCodex.has_any_progress()

func _on_new_game_pressed() -> void:
	GameManager.start_new_game()

func _on_continue_pressed() -> void:
	GameManager.continue_latest_game()

func _on_load_game_pressed() -> void:
	GameManager.open_load_game_screen()

func _on_story_map_pressed() -> void:
	GameManager.open_story_map_screen()

func _on_quit_pressed() -> void:
	GameManager.quit_game()
