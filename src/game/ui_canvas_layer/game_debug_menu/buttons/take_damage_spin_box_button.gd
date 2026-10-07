@tool
extends SubmitSpinBox


func _ready() -> void:
	super()
	button.pressed.connect(_on_pressed)
	
	
func _on_pressed() -> void:
	var target: Entity = SelectManager.selected_entity
	if not target:
		return

	var damage := Damage.new()
	damage.target_id = target.id
	damage.damage_type = Damage.Type.HP_MAX_PERCENT
	damage.value = spin_box.value / 100
	DamageManager.queue_insert_damage(damage)
