extends DebugMenuEditButton


func _ready() -> void:
	pressed.connect(_on_pressed)
	
	
func _on_pressed() -> void:
	var target: Entity = SelectMgr.selected_entity
	if not target:
		return

	var d := Damage.new()
	d.target_id = target.id
	d.damage_type = C.DamageType.HP_MAX_PERCENT
	d.value = float(line_edit.text) / 100
	d.insert_damage()
