class_name CodexEntry
extends Resource

## A single unlockable Collectables entry - a character, place, history
## record, or item. Referenced from story text via [codex:id]...[/codex]
## tags, or from StoryNode.unlocks / StoryChoice.unlocks.
##
## Fields are deliberately generic rather than one schema per category:
## `details` holds whatever labeled facts fit (Coordinates for a place,
## Date/Location for a history record, etc) so a brand new category never
## needs a new script - just populate whichever fields make sense and leave
## the rest empty.

@export var id: String = ""

## id of the CodexCategory this entry belongs to.
@export var category_id: String = ""

@export var title: String = ""

## Optional portrait/illustration shown in the detail view and popup.
@export var image: Texture2D

@export_multiline var description: String = ""

@export_multiline var backstory: String = ""

## Short bullet-point trivia (e.g. "Interesting Facts" for a character).
@export var facts: Array[String] = []

## Arbitrary labeled fields, e.g. {"Coordinates": "..."} for a place or
## {"Date": "...", "Location": "..."} for a history record.
@export var details: Dictionary = {}
