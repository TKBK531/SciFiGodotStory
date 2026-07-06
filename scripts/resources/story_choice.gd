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

## Minimum attribute/faction-trust values required for this choice to be
## selectable - id -> minimum value. Empty = no requirement.
@export var required_attributes: Dictionary = {}
@export var required_faction_trust: Dictionary = {}

## If a required_attributes/required_faction_trust threshold isn't met: true
## hides the choice entirely (like required_flags always does), false shows
## it disabled with a "Requires ..." hint instead.
@export var hide_if_locked: bool = true

## Attribute/faction-trust deltas applied to StoryState when the player picks
## this choice - id -> delta.
@export var attribute_changes: Dictionary = {}
@export var faction_changes: Dictionary = {}

@export var impact: Impact = Impact.NONE

## Codex entry ids unlocked when the player picks this specific choice.
@export var unlocks: Array[String] = []
