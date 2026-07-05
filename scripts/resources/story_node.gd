class_name StoryNode
extends Resource

## Unique identifier used to link choices to this node. Must be unique across
## every StoryNode resource in res://data/story/.
@export var id: String = ""

## Which StoryChapter this node belongs to - used to group nodes in the
## Story Map and to know which chapter to mark cleared/in-progress.
@export var chapter_id: String = ""

## Short title used only in the Story Map (falls back to id if empty). The
## full `text` below is the actual prose shown during gameplay.
@export var label: String = ""

@export_multiline var text: String = ""

## Optional illustration shown above the text for this node.
@export var image: Texture2D

## Flags applied automatically the moment this node is entered.
@export var set_flags_on_enter: Dictionary = {}

## Marks this node as concluding its chapter (an ending, or a chapter-close
## beat). Reaching it marks the chapter "cleared" in StoryCodex.
@export var is_chapter_end: bool = false

## Leave empty to make this node an ending.
@export var choices: Array[StoryChoice] = []
