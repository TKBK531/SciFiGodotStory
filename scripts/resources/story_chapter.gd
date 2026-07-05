class_name StoryChapter
extends Resource

## Unique identifier, referenced by StoryNode.chapter_id.
@export var id: String = ""

## Display order in the Story Map and chapter-select style lists.
@export var number: int = 1

@export var title: String = ""

## id of the StoryNode this chapter begins at.
@export var start_node_id: String = ""
