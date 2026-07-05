class_name SaveSlotsPanel
extends Control

## Reusable slot picker used both as the Pause Menu's "Save Game" page (mode
## SAVE) and as the Main Menu's "Load Game" screen (mode LOAD). Emits
## `closed` when the player wants to back out - the parent decides what
## that means (show pause buttons again, return to main menu, etc).

enum Mode { LOAD, SAVE }

signal closed

@export var mode: Mode = Mode.LOAD

@onready var title_label: Label = %TitleLabel
@onready var slots_container: VBoxContainer = %SlotsContainer
@onready var back_button: Button = %BackButton
@onready var confirm_dialog: ConfirmationDialog = %ConfirmDialog

var _pending_overwrite_slot: int = -1

func _ready() -> void:
	back_button.pressed.connect(func() -> void: closed.emit())
	confirm_dialog.confirmed.connect(_on_overwrite_confirmed)
	title_label.text = "Load Game" if mode == Mode.LOAD else "Save Game"
	refresh()

func refresh() -> void:
	for child in slots_container.get_children():
		child.queue_free()
	for slot in range(1, SaveManager.MAX_SLOTS + 1):
		slots_container.add_child(_build_slot_row(slot))

func _build_slot_row(slot: int) -> Button:
	var info := SaveManager.peek_slot(slot)
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 44)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if info.is_empty():
		button.text = "Slot %d — Empty" % slot
		button.disabled = mode == Mode.LOAD
	else:
		button.text = "Slot %d — %s" % [slot, info.get("timestamp", "saved")]
	button.pressed.connect(_on_slot_pressed.bind(slot, info))
	return button

func _on_slot_pressed(slot: int, info: Dictionary) -> void:
	if mode == Mode.LOAD:
		GameManager.continue_game(slot)
		return
	if info.is_empty():
		SaveManager.save_game(slot)
		refresh()
	else:
		_pending_overwrite_slot = slot
		confirm_dialog.dialog_text = "Overwrite Slot %d?" % slot
		confirm_dialog.popup_centered()

func _on_overwrite_confirmed() -> void:
	if _pending_overwrite_slot == -1:
		return
	SaveManager.save_game(_pending_overwrite_slot)
	_pending_overwrite_slot = -1
	refresh()
