extends Button


@export var confirmation_dialog: ConfirmationDialog = null


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	confirmation_dialog.popup_centered()
