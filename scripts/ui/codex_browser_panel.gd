class_name CodexBrowserPanel
extends Control

## Three-level visual browser: category "folders" first (a color-coded tile
## per category with its unlock count), then that category's entries as an
## image grid, then a full detail screen for one entry (image on the right,
## description/backstory/facts/details on the left). Unlocked tiles show the
## entry's illustration (or a category-colored placeholder if it has none
## yet); locked tiles show a dimmed placeholder and "???".

signal closed

const TILE_SIZE := Vector2(140, 140)
const PLACEHOLDER_SIZE := Vector2i(96, 96)

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
@onready var detail_body: RichTextLabel = %DetailBody
@onready var detail_image_rect: TextureRect = %DetailImageRect
@onready var detail_back_button: Button = %DetailBackButton

var _placeholder_cache: Dictionary = {}
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
	button.icon = _placeholder_texture(category.color)
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
		button.icon = entry.image if entry.image != null else _placeholder_texture(category.color)
		button.text = entry.title
		button.pressed.connect(_show_detail.bind(category, entry))
	else:
		button.icon = _placeholder_texture(category.color.darkened(0.6))
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
	detail_body.text = CodexText.build_entry_body(entry)
	detail_image_rect.texture = entry.image if entry.image != null else _placeholder_texture(category.color)

func _make_tile_button() -> Button:
	var button := Button.new()
	button.custom_minimum_size = TILE_SIZE
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	return button

## Solid-color square used as a category "folder" swatch, or as a stand-in
## for entries that don't have a real illustration yet - so every tile looks
## intentional even before art assets exist.
func _placeholder_texture(color: Color) -> ImageTexture:
	if _placeholder_cache.has(color):
		return _placeholder_cache[color]
	var image := Image.create(PLACEHOLDER_SIZE.x, PLACEHOLDER_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture := ImageTexture.create_from_image(image)
	_placeholder_cache[color] = texture
	return texture
