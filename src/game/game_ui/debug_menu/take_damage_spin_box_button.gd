@tool
extends SubmitSpinBox


func _ready() -> void:
	super()
	button.pressed.connect(_on_pressed)
	
	
func _on_pressed() -> void:
	var target: Entity = SelectMgr.selected_entity
	if not U.is_valid_entity(target):
		return

	var d := Damage.new()
	d.target_id = target.id
	d.damage_type = C.DamageType.HP_MAX_PERCENT
	d.value = spin_box.value / 100
	d.insert_damage()
