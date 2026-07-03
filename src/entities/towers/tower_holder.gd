@tool
extends Entity


@export var default_rally_center_local_pos := Vector2.ZERO:
	set(v):
		default_rally_center_local_pos = v
		if tower_c:
			tower_c.default_rally_center_local_pos = default_rally_center_local_pos
		update_configuration_warnings()

			
@export_group("Ref")
@export var tower_c: TowerComponent = null

	
func _ready() -> void:
	super()
	tower_c.default_rally_center_local_pos = default_rally_center_local_pos


func _get_configuration_warnings() -> PackedStringArray:
	if default_rally_center_local_pos == Vector2.ZERO:
		return ["请在 default_rally_center_local_pos 中设置一个默认集结点位置。"]
		
	return []
