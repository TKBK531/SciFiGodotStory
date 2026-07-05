extends CanvasLayer

## Global overlay (autoloaded as a scene) for a quick, non-disruptive look at
## a codex entry clicked inline during gameplay - CodexEntryPopup.show_entry
## ("voss"). The Collectables browser uses its own full detail screen
## instead, since browsing there is a deliberate "go look at this" action
## rather than a quick reference mid-story.

@onready var category_label: Label = %CategoryLabel
@onready var title_label: Label = %TitleLabel
@onready var illustration_frame: PanelContainer = %IllustrationFrame
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
	if category != null:
		category_label.text = category.label.to_upper()
		category_label.add_theme_color_override("font_color", category.color)
	else:
		category_label.text = ""
	title_label.text = entry.title
	description_label.text = CodexText.build_entry_body(entry)
	image_rect.texture = entry.image
	illustration_frame.visible = entry.image != null
	visible = true

func hide_popup() -> void:
	visible = false

func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		hide_popup()
