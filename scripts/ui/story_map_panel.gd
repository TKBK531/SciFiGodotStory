class_name StoryMapPanel
extends Control

## Reusable Story Map browser: a chapter list, drilling into a per-chapter
## list of decision points. Each impactful choice at a decision point renders
## as taken (this history), discovered (StoryCodex knows it from elsewhere),
## or hidden (never taken anywhere - shown as a locked marker, no text).

signal closed

enum ChoiceState { TAKEN, DISCOVERED, HIDDEN }

@onready var list_view: Control = %ListView
@onready var detail_view: Control = %DetailView
@onready var chapters_container: VBoxContainer = %ChaptersContainer
@onready var detail_title: Label = %DetailTitle
@onready var decisions_container: VBoxContainer = %DecisionsContainer
@onready var list_back_button: Button = %ListBackButton
@onready var detail_back_button: Button = %DetailBackButton

var _history: Array[String] = []
var _taken_edges: Dictionary = {}

func _ready() -> void:
	list_back_button.pressed.connect(func() -> void: closed.emit())
	detail_back_button.pressed.connect(_show_list)

## history is the ordered sequence of node ids for the playthrough whose path
## should be highlighted (live StoryState.history, or a peeked save slot's).
func open_with_history(history: Array[String]) -> void:
	_history = history
	_taken_edges.clear()
	for i in range(_history.size() - 1):
		_taken_edges[_edge_key(_history[i], _history[i + 1])] = true
	_show_list()

func _show_list() -> void:
	detail_view.visible = false
	list_view.visible = true
	_populate_chapter_list()

func _populate_chapter_list() -> void:
	for child in chapters_container.get_children():
		child.queue_free()
	for chapter in ChapterDatabase.get_all_ordered():
		chapters_container.add_child(_build_chapter_row(chapter))

func _build_chapter_row(chapter: StoryChapter) -> Button:
	var started := StoryCodex.is_chapter_started(chapter.id)
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 44)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not started:
		button.text = "Chapter %d — ???" % chapter.number
		button.disabled = true
	else:
		var status := "Cleared" if StoryCodex.is_chapter_cleared(chapter.id) else "In Progress"
		button.text = "Chapter %d — %s (%s)" % [chapter.number, chapter.title, status]
		button.pressed.connect(_show_detail.bind(chapter))
	return button

func _show_detail(chapter: StoryChapter) -> void:
	list_view.visible = false
	detail_view.visible = true
	detail_title.text = "Chapter %d — %s" % [chapter.number, chapter.title]
	_populate_decisions(chapter)

func _populate_decisions(chapter: StoryChapter) -> void:
	for child in decisions_container.get_children():
		child.queue_free()
	for node in _collect_decision_nodes(chapter):
		if not (StoryCodex.is_node_visited(node.id) or _history.has(node.id)):
			continue
		decisions_container.add_child(_build_decision_block(node))

## Walks the static story graph from the chapter's start node, staying within
## this chapter, and returns every node that has at least one impactful
## choice - regardless of whether the player has ever reached it (visibility
## filtering happens separately in _populate_decisions).
func _collect_decision_nodes(chapter: StoryChapter) -> Array[StoryNode]:
	var result: Array[StoryNode] = []
	var seen: Dictionary = {}
	var queue: Array[String] = [chapter.start_node_id]
	while not queue.is_empty():
		var node_id: String = queue.pop_front()
		if seen.has(node_id):
			continue
		seen[node_id] = true
		var node := StoryDatabase.get_node_by_id(node_id)
		if node == null or node.chapter_id != chapter.id:
			continue
		var has_decision := false
		for choice in node.choices:
			if choice.impact != StoryChoice.Impact.NONE:
				has_decision = true
			queue.append(choice.target_node_id)
		if has_decision:
			result.append(node)
	return result

func _build_decision_block(node: StoryNode) -> Control:
	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", 4)

	var title := Label.new()
	title.text = node.label if not node.label.is_empty() else node.id
	title.add_theme_font_size_override("font_size", 18)
	block.add_child(title)

	for choice in node.choices:
		if choice.impact == StoryChoice.Impact.NONE:
			continue
		block.add_child(_build_choice_row(node.id, choice))

	return block

func _build_choice_row(from_node_id: String, choice: StoryChoice) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var marker := Label.new()
	var text_label := Label.new()

	match _choice_state(from_node_id, choice.target_node_id):
		ChoiceState.TAKEN:
			marker.text = ">"
			text_label.text = choice.text
			text_label.modulate = Color(1, 1, 1, 1)
		ChoiceState.DISCOVERED:
			marker.text = "-"
			text_label.text = choice.text
			text_label.modulate = Color(1, 1, 1, 0.55)
		ChoiceState.HIDDEN:
			marker.text = "?"
			text_label.text = "Hidden choice"
			text_label.modulate = Color(1, 1, 1, 0.35)

	if choice.impact == StoryChoice.Impact.MAJOR:
		text_label.add_theme_color_override("font_color", Color(0.94, 0.55, 0.4))

	row.add_child(marker)
	row.add_child(text_label)
	return row

func _choice_state(from_node_id: String, to_node_id: String) -> ChoiceState:
	if _taken_edges.has(_edge_key(from_node_id, to_node_id)):
		return ChoiceState.TAKEN
	if StoryCodex.is_choice_discovered(from_node_id, to_node_id):
		return ChoiceState.DISCOVERED
	return ChoiceState.HIDDEN

func _edge_key(from_node_id: String, to_node_id: String) -> String:
	return "%s::%s" % [from_node_id, to_node_id]
