class_name StoryNode
extends Resource

## Unique identifier used to link choices to this node. Must be unique across
## every StoryNode resource in res://data/story/.
@export var id: String = ""

@export_multiline var text: String = ""

## Optional illustration shown above the text for this node.
@export var image: Texture2D

## Flags applied automatically the moment this node is entered.
@export var set_flags_on_enter: Dictionary = {}

## Leave empty to make this node an ending.
@export var choices: Array[StoryChoice] = []
