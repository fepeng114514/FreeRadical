@tool
extends Entity


## 默认集结点局部位置。
@export var default_rally_center_position := Vector2.ZERO:
	set(v):
		default_rally_center_position = v
		if tower_c:
			tower_c.default_rally_center_position = default_rally_center_position
		update_configuration_warnings()

@export_group("Ref")
@export var tower_c: TowerComponent = null

	
func _ready() -> void:
	super()
	tower_c.default_rally_center_position = default_rally_center_position


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
		
	if not default_rally_center_position:
		warnings.append("请在 default_rally_center_position 中设置一个默认集结点位置。")
		
	return warnings
