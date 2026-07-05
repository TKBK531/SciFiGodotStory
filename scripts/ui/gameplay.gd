extends Control

## Drives the story: shows the current StoryNode's text with a typewriter
## effect, reveals its optional image, and builds choice buttons dynamically
## from whichever choices currently satisfy StoryState's flags. Story text
## may contain [codex:id]Label[/codex] mentions - these unlock the entry and
## render as clickable, category-colored links that open CodexEntryPopup.

@onready var background: TextureRect = %Background
@onready var story_text: RichTextLabel = %StoryText
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var pause_button: Button = %PauseButton

const CHARS_PER_SECOND: float = 45.0

var _typing_tween: Tween
var _current_node: StoryNode
var _text_fully_shown: bool = true

func _ready() -> void:
	pause_button.pressed.connect(_on_pause_pressed)
	story_text.mouse_filter = Control.MOUSE_FILTER_PASS
	story_text.meta_clicked.connect(_on_codex_link_clicked)
	story_text.meta_hover_started.connect(func(_meta: Variant) -> void: story_text.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND)
	story_text.meta_hover_ended.connect(func(_meta: Variant) -> void: story_text.mouse_default_cursor_shape = Control.CURSOR_ARROW)
	var start_id := StoryState.current_node_id
	if start_id.is_empty():
		start_id = StoryState.START_NODE_ID
	_goto_node(start_id)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameManager.toggle_pause()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not _text_fully_shown:
			_skip_typing()

func _goto_node(node_id: String) -> void:
	var node := StoryDatabase.get_node_by_id(node_id)
	if node == null:
		push_error("Gameplay: story node '%s' not found." % node_id)
		return
	_current_node = node
	StoryState.goto_node(node_id)
	StoryCodex.record_node_visit(node)
	for flag_name in node.set_flags_on_enter:
		StoryState.set_flag(flag_name, node.set_flags_on_enter[flag_name])
	for entry_id in node.unlocks:
		StoryCodex.unlock_entry(entry_id)
	for entry_id in CodexText.extract_codex_ids(node.text):
		StoryCodex.unlock_entry(entry_id)
	background.texture = node.image
	background.visible = node.image != null
	_clear_choices()
	_type_text(node.text)

func _type_text(full_text: String) -> void:
	if _typing_tween and _typing_tween.is_valid():
		_typing_tween.kill()
	_text_fully_shown = false
	story_text.text = CodexText.expand_codex_tags(full_text)
	story_text.visible_characters = 0
	var total_chars := story_text.get_total_character_count()
	var duration: float = max(total_chars / CHARS_PER_SECOND, 0.05)
	_typing_tween = create_tween()
	_typing_tween.tween_property(story_text, "visible_characters", total_chars, duration)
	_typing_tween.finished.connect(_on_typing_finished)

func _skip_typing() -> void:
	if _typing_tween and _typing_tween.is_valid():
		_typing_tween.kill()
	story_text.visible_characters = -1
	_on_typing_finished()

func _on_typing_finished() -> void:
	_text_fully_shown = true
	_populate_choices()

func _populate_choices() -> void:
	_clear_choices()
	var available: Array[StoryChoice] = []
	for choice in _current_node.choices:
		if StoryState.meets_requirements(choice.required_flags):
			available.append(choice)
	if available.is_empty():
		var end_label := Label.new()
		end_label.text = "— The End —"
		end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		choices_container.add_child(end_label)
		return
	for choice in available:
		var button := Button.new()
		button.text = choice.text
		button.pressed.connect(_on_choice_selected.bind(choice))
		choices_container.add_child(button)

func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

func _on_choice_selected(choice: StoryChoice) -> void:
	StoryCodex.record_choice(_current_node.id, choice.target_node_id)
	for entry_id in choice.unlocks:
		StoryCodex.unlock_entry(entry_id)
	for flag_name in choice.set_flags:
		StoryState.set_flag(flag_name, choice.set_flags[flag_name])
	_goto_node(choice.target_node_id)

func _on_pause_pressed() -> void:
	GameManager.toggle_pause()

func _on_codex_link_clicked(meta: Variant) -> void:
	CodexEntryPopup.show_entry(str(meta))
