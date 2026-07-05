class_name StoryChoice
extends Resource

## Text shown on the choice button.
@export var text: String = ""

## id of the StoryNode this choice leads to.
@export var target_node_id: String = ""

## Flags that must all match for this choice to be shown. Empty = always shown.
@export var required_flags: Dictionary = {}

## Flags applied to StoryState when the player picks this choice.
@export var set_flags: Dictionary = {}
