class_name AttributeDefinition
extends Resource

## Data-driven character attribute (Courage, Empathy, etc.) - drop a new .tres
## into res://data/attributes/ to add one, no code changes needed. Mirrors
## CodexCategory's authoring pattern.

@export var id: String = ""
@export var label: String = ""
@export var color: Color = Color.WHITE

@export var min_value: float = 0.0
@export var max_value: float = 10.0
@export var starting_value: float = 0.0

## Display order in the Stats panel.
@export var sort_order: int = 0
