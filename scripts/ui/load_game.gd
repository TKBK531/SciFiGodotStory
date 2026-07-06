extends Control

@onready var save_slots_panel: SaveSlotsPanel = %SaveSlotsPanel

func _ready() -> void:
	save_slots_panel.closed.connect(_on_closed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_closed()

func _on_closed() -> void:
	GameManager.return_to_main_menu()
