class_name StatsPanel
extends Control

## Reusable read-only view of the player's current attributes and faction
## trust levels - shown from the Pause Menu. Mirrors StoryMapPanel/
## SaveSlotsPanel's "emit closed, parent decides what that means" pattern.

signal closed

@onready var attributes_container: VBoxContainer = %AttributesContainer
@onready var factions_container: VBoxContainer = %FactionsContainer
@onready var back_button: Button = %BackButton

func _ready() -> void:
	back_button.pressed.connect(func() -> void: closed.emit())
	refresh()

func refresh() -> void:
	_populate(attributes_container, AttributeDatabase.get_all_ordered(), StoryState.attributes)
	_populate(factions_container, FactionDatabase.get_all_ordered(), StoryState.faction_trust)

func _populate(container: VBoxContainer, definitions: Array, current_values: Dictionary) -> void:
	for child in container.get_children():
		child.queue_free()
	for definition in definitions:
		container.add_child(_build_row(definition, current_values.get(definition.id, definition.starting_value)))

## Untyped on purpose: definition is either an AttributeDefinition or a
## FactionDefinition - same shape, no common base class with these fields.
func _build_row(definition, value: float) -> Control:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)

	var header := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = definition.label
	name_label.add_theme_color_override("font_color", definition.color)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var value_label := Label.new()
	value_label.text = "%d / %d" % [value, definition.max_value]
	header.add_child(name_label)
	header.add_child(value_label)

	var bar := ProgressBar.new()
	bar.min_value = definition.min_value
	bar.max_value = definition.max_value
	bar.value = value
	bar.show_percentage = false

	row.add_child(header)
	row.add_child(bar)
	return row
