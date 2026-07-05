class_name CodexCategory
extends Resource

## Data-driven category for codex entries (Characters, Places, History,
## Collectables, or anything added later) - adding a new category is just a
## new .tres file, no code changes.

@export var id: String = ""
@export var label: String = ""
@export var color: Color = Color.WHITE

## Display order in the Collectables screen and inline text tint priority.
@export var sort_order: int = 0
