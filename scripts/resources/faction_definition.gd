class_name FactionDefinition
extends Resource

## Data-driven faction (Government, Townspeople, etc.) whose trust in the
## player rises or falls with choices - drop a new .tres into
## res://data/factions/ to add one, no code changes needed. Mirrors
## AttributeDefinition/CodexCategory's authoring pattern.

@export var id: String = ""
@export var label: String = ""
@export var color: Color = Color.WHITE

@export var min_value: float = -100.0
@export var max_value: float = 100.0
@export var starting_value: float = 0.0

## Display order in the Stats panel.
@export var sort_order: int = 0
