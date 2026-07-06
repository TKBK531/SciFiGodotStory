extends Control

@onready var story_map_panel: StoryMapPanel = %StoryMapPanel

func _ready() -> void:
	story_map_panel.closed.connect(_on_closed)
	story_map_panel.open_with_history(_latest_save_history())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_closed()

func _on_closed() -> void:
	GameManager.return_to_main_menu()

func _latest_save_history() -> Array[String]:
	var history: Array[String] = []
	var slot := SaveManager.get_latest_slot()
	if slot == -1:
		return history
	var save_data := SaveManager.peek_slot(slot)
	var raw_history: Array = save_data.get("history", [])
	for node_id in raw_history:
		history.append(node_id)
	return history
