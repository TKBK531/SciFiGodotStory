class_name CodexBrowserPanel
extends Control

## Three-level visual browser: category "folders" first (a color-coded tile
## per category with its unlock count), then that category's entries as an
## image grid, then a full detail screen for one entry. Each category picks
## its own detail layout (image left / image right / full-width image on
## top with details below) via CodexCategory.detail_layout - a data field,
## not a hardcoded per-category branch, so a new category just declares
## which layout it wants and gets it for free.

signal closed

const TILE_SIZE := Vector2(140, 140)
const TILE_ICON_SIZE := Vector2i(96, 96)
const SIDE_IMAGE_WIDTH := 320.0
const TOP_IMAGE_HEIGHT := 280.0

@onready var categories_view: Control = %CategoriesView
@onready var categories_grid: GridContainer = %CategoriesGrid
@onready var categories_back_button: Button = %CategoriesBackButton

@onready var entries_view: Control = %EntriesView
@onready var entries_title: Label = %EntriesTitle
@onready var entries_grid: GridContainer = %EntriesGrid
@onready var entries_back_button: Button = %EntriesBackButton

@onready var detail_view: Control = %DetailView
@onready var detail_category_label: Label = %DetailCategoryLabel
@onready var detail_title_label: Label = %DetailTitleLabel
@onready var detail_content: Control = %DetailContent
@onready var detail_back_button: Button = %DetailBackButton

var _current_category: CodexCategory

func _ready() -> void:
	categories_back_button.pressed.connect(func() -> void: closed.emit())
	entries_back_button.pressed.connect(_show_categories)
	detail_back_button.pressed.connect(_show_entries.bind(null))
	refresh()

func refresh() -> void:
	_show_categories()

func _show_categories() -> void:
	detail_view.visible = false
	entries_view.visible = false
	categories_view.visible = true
	_populate_categories()

func _populate_categories() -> void:
	# Safe to free immediately (not queue_free): these tiles never trigger
	# their own container's repopulation, unlike SaveSlotsPanel/StoryMapPanel
	# where a tile's own click handler clears its own parent.
	for child in categories_grid.get_children():
		child.free()
	for category in CodexDatabase.get_categories_ordered():
		categories_grid.add_child(_build_category_tile(category))

func _build_category_tile(category: CodexCategory) -> Button:
	var entries := CodexDatabase.get_entries_for_category(category.id)
	var unlocked_count := 0
	for entry in entries:
		if StoryCodex.is_entry_unlocked(entry.id):
			unlocked_count += 1
	var button := _make_tile_button()
	button.icon = CodexText.placeholder_texture(category.color, TILE_ICON_SIZE)
	button.text = "%s\n%d/%d" % [category.label, unlocked_count, entries.size()]
	button.pressed.connect(_show_entries.bind(category))
	return button

func _show_entries(category: CodexCategory) -> void:
	if category == null:
		category = _current_category
	_current_category = category
	detail_view.visible = false
	categories_view.visible = false
	entries_view.visible = true
	entries_title.text = category.label
	_populate_entries(category)

func _populate_entries(category: CodexCategory) -> void:
	for child in entries_grid.get_children():
		child.free()
	for entry in CodexDatabase.get_entries_for_category(category.id):
		entries_grid.add_child(_build_entry_tile(category, entry))

func _build_entry_tile(category: CodexCategory, entry: CodexEntry) -> Button:
	var button := _make_tile_button()
	if StoryCodex.is_entry_unlocked(entry.id):
		button.icon = entry.image if entry.image != null else CodexText.placeholder_texture(category.color, TILE_ICON_SIZE)
		button.text = entry.title
		button.pressed.connect(_show_detail.bind(category, entry))
	else:
		button.icon = CodexText.placeholder_texture(category.color.darkened(0.6), TILE_ICON_SIZE)
		button.text = "???"
		button.disabled = true
	return button

func _show_detail(category: CodexCategory, entry: CodexEntry) -> void:
	_current_category = category
	categories_view.visible = false
	entries_view.visible = false
	detail_view.visible = true
	detail_category_label.text = category.label.to_upper()
	detail_category_label.add_theme_color_override("font_color", category.color)
	detail_title_label.text = entry.title
	_populate_detail_content(category, entry)

## Builds the image+body layout fresh each time, since the arrangement
## (which side the image sits on, or full-width-on-top) depends on the
## category being viewed, not just the entry.
func _populate_detail_content(category: CodexCategory, entry: CodexEntry) -> void:
	for child in detail_content.get_children():
		child.free()

	var image_frame := _build_image_frame(category, entry)
	var body_scroll := _build_body_scroll(entry)
	var container: Control

	if category.detail_layout == CodexCategory.DetailLayout.IMAGE_TOP_FULL_WIDTH:
		image_frame.custom_minimum_size = Vector2(0, TOP_IMAGE_HEIGHT)
		image_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 16)
		col.add_child(image_frame)
		col.add_child(body_scroll)
		container = col
	else:
		image_frame.custom_minimum_size = Vector2(SIDE_IMAGE_WIDTH, 0)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 24)
		if category.detail_layout == CodexCategory.DetailLayout.IMAGE_LEFT:
			row.add_child(image_frame)
			row.add_child(body_scroll)
		else:
			row.add_child(body_scroll)
			row.add_child(image_frame)
		container = row

	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	detail_content.add_child(container)

func _build_image_frame(category: CodexCategory, entry: CodexEntry) -> PanelContainer:
	var frame := PanelContainer.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	var image_rect := TextureRect.new()
	image_rect.expand_mode = 1
	image_rect.stretch_mode = 5
	image_rect.texture = entry.image if entry.image != null else CodexText.placeholder_texture(category.color)
	margin.add_child(image_rect)
	frame.add_child(margin)
	return frame

func _build_body_scroll(entry: CodexEntry) -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var body := RichTextLabel.new()
	body.bbcode_enabled = true
	body.fit_content = true
	body.scroll_active = false
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.text = CodexText.build_entry_body(entry)
	scroll.add_child(body)
	return scroll

func _make_tile_button() -> Button:
	var button := Button.new()
	button.custom_minimum_size = TILE_SIZE
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	return button
