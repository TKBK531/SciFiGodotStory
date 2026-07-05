extends Control

@onready var continue_button: Button = %ContinueButton
@onready var load_game_button: Button = %LoadGameButton

func _ready() -> void:
	var any_save := SaveManager.has_any_save()
	continue_button.disabled = not any_save
	load_game_button.disabled = not any_save

func _on_new_game_pressed() -> void:
	GameManager.start_new_game()

func _on_continue_pressed() -> void:
	GameManager.continue_latest_game()

func _on_load_game_pressed() -> void:
	GameManager.open_load_game_screen()

func _on_quit_pressed() -> void:
	GameManager.quit_game()
