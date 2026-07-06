extends CanvasLayer

## Instanced as a child of the gameplay scene. Its process_mode (ALWAYS) and
## initial visibility (false) are set on the scene's root node so it keeps
## working while the SceneTree is paused.

@onready var main_buttons: Control = %MainButtons
@onready var save_slots_panel: SaveSlotsPanel = %SaveSlotsPanel
@onready var story_map_panel: StoryMapPanel = %StoryMapPanel
@onready var stats_panel: StatsPanel = %StatsPanel

func _ready() -> void:
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)
	save_slots_panel.closed.connect(_show_main_buttons)
	story_map_panel.closed.connect(_show_main_buttons)
	stats_panel.closed.connect(_show_main_buttons)

func _on_game_paused() -> void:
	visible = true
	_show_main_buttons()

func _on_game_resumed() -> void:
	visible = false

func _show_main_buttons() -> void:
	main_buttons.visible = true
	save_slots_panel.visible = false
	story_map_panel.visible = false
	stats_panel.visible = false

func _on_resume_pressed() -> void:
	GameManager.resume_game()

func _on_save_pressed() -> void:
	main_buttons.visible = false
	save_slots_panel.visible = true
	save_slots_panel.refresh()

func _on_story_map_pressed() -> void:
	main_buttons.visible = false
	story_map_panel.visible = true
	story_map_panel.open_with_history(StoryState.history)

func _on_stats_pressed() -> void:
	main_buttons.visible = false
	stats_panel.visible = true
	stats_panel.refresh()

func _on_main_menu_pressed() -> void:
	GameManager.return_to_main_menu()

func _on_quit_pressed() -> void:
	GameManager.quit_game()
