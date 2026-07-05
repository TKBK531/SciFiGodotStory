extends CanvasLayer

## Global overlay (autoloaded as a scene) for a quick, non-disruptive look at
## a codex entry clicked inline during gameplay - CodexEntryPopup.show_entry
## ("voss"). The Collectables browser uses its own full detail screen
## instead, since browsing there is a deliberate "go look at this" action
## rather than a quick reference mid-story.
##
## Visually accented per-category: the panel gets a colored border/glow and
## the category badge gets a tinted background, both built from
## CodexCategory.color at show-time rather than being fixed in the theme -
## so every entry reads as "this is a Character" vs "this is a Place" at a
## glance, not just via a small text label.

@onready var panel: PanelContainer = %Panel
@onready var category_chip: PanelContainer = %CategoryChip
@onready var category_label: Label = %CategoryLabel
@onready var title_label: Label = %TitleLabel
@onready var image_rect: TextureRect = %ImageRect
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var close_button: Button = %CloseButton
@onready var dim_background: ColorRect = %DimBackground

func _ready() -> void:
	visible = false
	close_button.pressed.connect(hide_popup)
	dim_background.gui_input.connect(_on_dim_input)

func show_entry(entry_id: String) -> void:
	var entry := CodexDatabase.get_entry(entry_id)
	if entry == null:
		push_warning("CodexEntryPopup: unknown codex entry '%s'." % entry_id)
		return
	var category := CodexDatabase.get_category(entry.category_id)
	var accent_color := category.color if category != null else Color.WHITE

	category_label.text = category.label.to_upper() if category != null else ""
	category_label.add_theme_color_override("font_color", accent_color)
	_style_chip(accent_color)
	_style_panel_accent(accent_color)

	title_label.text = entry.title
	description_label.text = CodexText.build_entry_body(entry)
	image_rect.texture = entry.image if entry.image != null else CodexText.placeholder_texture(accent_color)

	visible = true
	_play_open_animation()

func hide_popup() -> void:
	visible = false

func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		hide_popup()

func _play_open_animation() -> void:
	panel.modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.15)

func _style_chip(color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 0.22)
	style.set_corner_radius_all(10)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	category_chip.add_theme_stylebox_override("panel", style)

func _style_panel_accent(color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.106, 0.118, 0.169, 0.96)
	style.set_corner_radius_all(18)
	style.set_border_width_all(2)
	style.border_color = color
	style.shadow_color = Color(color.r, color.g, color.b, 0.35)
	style.shadow_size = 14
	panel.add_theme_stylebox_override("panel", style)
