extends Node2D


var selected_entity: Entity = null


func _ready() -> void:
	S.select_entity_s.connect(_on_select_entity)
	S.deselect_entity_s.connect(_on_deselect_entity)


func _on_select_entity(e: Entity) -> void:
	selected_entity = e
	queue_redraw()
	
	
func _on_deselect_entity() -> void:
	selected_entity = null
	queue_redraw()


func _draw() -> void:
	if not selected_entity:
		return
	
	var center: Vector2 = selected_entity.global_position
	
	if selected_entity.has_c(C.CN_RANGED):
		var ranged_c: RangedComponent = selected_entity.get_c(C.CN_RANGED)
		var radius: float = ranged_c.order[0].max_range
		var color := Color(0.0, 0.898, 0.278, 0.263)
	
		# 实心圆
		draw_circle(center, radius, color)
		
	if selected_entity.has_c(C.CN_TOWER):
		var tower_c: TowerComponent = selected_entity.get_c(C.CN_TOWER)
		var radius: float = tower_c.max_range
		var color := Color(0.0, 0.898, 0.278, 0.263)
	
		# 实心圆
		draw_circle(center, radius, color)
