class_name StoryChoice
extends Resource

## How much this choice matters to the overall story - drives whether (and
## how) it shows up on the Story Map. NONE choices never appear there at all
## (e.g. a single "continue" option isn't a real decision).
enum Impact { NONE, MINOR, MAJOR }

## Text shown on the choice button.
@export var text: String = ""

## id of the StoryNode this choice leads to.
@export var target_node_id: String = ""

## Flags that must all match for this choice to be shown. Empty = always shown.
@export var required_flags: Dictionary = {}

## Flags applied to StoryState when the player picks this choice.
@export var set_flags: Dictionary = {}

@export var impact: Impact = Impact.NONE

## Codex entry ids unlocked when the player picks this specific choice.
@export var unlocks: Array[String] = []
