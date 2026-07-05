extends Control

@onready var codex_browser_panel: CodexBrowserPanel = %CodexBrowserPanel

func _ready() -> void:
	codex_browser_panel.closed.connect(_on_closed)

func _on_closed() -> void:
	GameManager.return_to_main_menu()
