class_name CodexText
extends RefCounted

## Parses `[codex:id]Label[/codex]` markup out of raw StoryNode text.
## Authors write plain, color-agnostic tags; this expands them into Godot's
## native clickable BBCode ([url]+[color]), tinted per the entry's
## CodexCategory - so recoloring a whole category is a one-file data change,
## never a find-and-replace across story text.

static var _tag_regex: RegEx
static var _id_regex: RegEx
static var _placeholder_cache: Dictionary = {}

static func _ensure_regex() -> void:
	if _tag_regex == null:
		_tag_regex = RegEx.new()
		_tag_regex.compile("\\[codex:([a-zA-Z0-9_]+)\\](.*?)\\[/codex\\]")
	if _id_regex == null:
		_id_regex = RegEx.new()
		_id_regex.compile("\\[codex:([a-zA-Z0-9_]+)\\]")

## Every distinct codex entry id referenced anywhere in `source`.
static func extract_codex_ids(source: String) -> Array[String]:
	_ensure_regex()
	var ids: Array[String] = []
	for m in _id_regex.search_all(source):
		var id := m.get_string(1)
		if not ids.has(id):
			ids.append(id)
	return ids

## Replaces every [codex:id]Label[/codex] with a clickable, category-colored
## [url]/[color] BBCode span. Unknown ids fall back to plain white text
## rather than failing, so a typo doesn't break the whole page.
static func expand_codex_tags(source: String) -> String:
	_ensure_regex()
	var matches := _tag_regex.search_all(source)
	if matches.is_empty():
		return source
	var result := ""
	var cursor := 0
	for m in matches:
		result += source.substr(cursor, m.get_start() - cursor)
		result += _render_link(m.get_string(1), m.get_string(2))
		cursor = m.get_end()
	result += source.substr(cursor)
	return result

static func _render_link(entry_id: String, label: String) -> String:
	var color := Color.WHITE
	var entry := CodexDatabase.get_entry(entry_id)
	if entry != null:
		var category := CodexDatabase.get_category(entry.category_id)
		if category != null:
			color = category.color
	# [color] must wrap [url], not the other way around - Godot's RichTextLabel
	# doesn't reliably apply a [color] nested inside a [url] meta span.
	return "[color=#%s][url=%s]%s[/url][/color]" % [color.to_html(false), entry_id, label]

## Composes an entry's description/backstory/facts/details into one bbcode
## body, skipping whichever fields are empty - shared by CodexEntryPopup
## (gameplay quick-look) and CodexBrowserPanel's detail screen so both
## surfaces render an entry identically regardless of which category it's in.
static func build_entry_body(entry: CodexEntry) -> String:
	var parts: Array[String] = []
	if not entry.details.is_empty():
		var detail_lines: Array[String] = []
		for key in entry.details:
			detail_lines.append("[b]%s:[/b] %s" % [key, entry.details[key]])
		parts.append("\n".join(detail_lines))
	if not entry.description.is_empty():
		parts.append(entry.description)
	if not entry.backstory.is_empty():
		parts.append("[b]Backstory[/b]\n%s" % entry.backstory)
	if not entry.facts.is_empty():
		var fact_lines: Array[String] = []
		for fact in entry.facts:
			fact_lines.append("• %s" % fact)
		parts.append("[b]Interesting Facts[/b]\n%s" % "\n".join(fact_lines))
	return "\n\n".join(parts)

## Solid-color square usable as a category "folder" swatch or as a stand-in
## illustration for entries that don't have real art yet - shared by
## CodexBrowserPanel and CodexEntryPopup so both look intentional even
## before art assets exist.
static func placeholder_texture(color: Color, size: Vector2i = Vector2i(128, 128)) -> ImageTexture:
	var key := "%s_%dx%d" % [color.to_html(true), size.x, size.y]
	if _placeholder_cache.has(key):
		return _placeholder_cache[key]
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture := ImageTexture.create_from_image(image)
	_placeholder_cache[key] = texture
	return texture
