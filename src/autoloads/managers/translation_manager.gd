extends Node


func _ready() -> void:
	var preferred_language: String = OS.get_locale_language()
	TranslationServer.set_locale(preferred_language)
