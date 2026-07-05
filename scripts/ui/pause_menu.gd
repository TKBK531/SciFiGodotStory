extends CanvasLayer

## Instanced as a child of the gameplay scene. Its process_mode (ALWAYS) and
## initial visibility (false) are set on the scene's root node so it keeps
## working while the SceneTree is paused.

@onready var main_buttons: Control = %MainButtons
@onready var save_slots_panel: SaveSlotsPanel = %SaveSlotsPanel

func _ready() -> void:
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)
	save_slots_panel.closed.connect(_show_main_buttons)

func _on_game_paused() -> void:
	visible = true
	_show_main_buttons()

func _on_game_resumed() -> void:
	visible = false

func _show_main_buttons() -> void:
	main_buttons.visible = true
	save_slots_panel.visible = false

func _on_resume_pressed() -> void:
	GameManager.resume_game()

func _on_save_pressed() -> void:
	main_buttons.visible = false
	save_slots_panel.visible = true
	save_slots_panel.refresh()

func _on_main_menu_pressed() -> void:
	GameManager.return_to_main_menu()

func _on_quit_pressed() -> void:
	GameManager.quit_game()
