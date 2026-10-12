@tool
extends Component
class_name BarrackComponent
## 兵营组件。
##
## [BarrackComponent] 可以让实体生成士兵。


@export var config: BarrackComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 生成士兵的时间戳（秒）
var spawn_timestamp: float = 0.0
## 是否需要重置集结点全局位置。
var need_reset_rally_center_global_position: bool = false


func _draw() -> void:
	if not config:
		return
		
	if DebugManager.draw_offset_enabled:
		if config.spawn_offsets:
			config.spawn_offsets.draw_offset_group(self)
		
	if DebugManager.draw_range_enabled:
		Utils.draw_range_ellipse(self, position, config.rally_min_range, config.rally_max_range, Color(0.201, 0.431, 1.0, 0.2))

	if DebugManager.draw_point_enabled:
		var barrack_record: BarrackRecord = parent.get_node_or_null(Constants.BARRACK_RECORD_NODE_PATH)
		if barrack_record:
			var rally_center_position: Vector2 = to_local(barrack_record.rally_center_global_position)
			draw_circle(
				rally_center_position,
				9,
				Color.BLUE, 
				true
			)
			draw_line(
				rally_center_position, 
				position, 
				Color.BLUE, 
				2
			)

			for i: int in config.max_soldier_count:
				var formation_position: Vector2 = to_formation_position(rally_center_position, config.max_soldier_count, i)
				draw_circle(
					formation_position,
					3,
					Color.BLUE, 
					true
				)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	for warning in BarrackRecord.get_not_found_configuration_warnings(parent):
		warnings.append(warning)

	return warnings


## 设置所有士兵的集结点全局位置。
func set_all_rally_center_global_position(
		center_global_position: Vector2, 
		is_forced: bool = false,
		play_sfx: bool = true
	) -> void:
	if play_sfx:
		AudioManager.play_sfx(config.rally_sfx)
		
	var barrack_record: BarrackRecord = parent.get_node_or_null(Constants.BARRACK_RECORD_NODE_PATH)
	barrack_record.rally_center_global_position = center_global_position
	var soldier_ids: PackedInt32Array = barrack_record.soldier_ids
	var soldier_size: int = soldier_ids.size()
	for soldier_index: int in soldier_size:
		var soldier: Entity = EntityManager.get_entity_by_id(soldier_ids[soldier_index])
		set_rally_center_global_position(center_global_position, soldier, soldier_index, soldier_size, is_forced)


## 设置单个士兵的集结点全局位置。
func set_rally_center_global_position(
		center_global_position: Vector2, 
		soldier: Entity,
		soldier_index: int,
		soldier_count: int,
		is_forced: bool = false,
	) -> void:
	var soldier_rally_c: RallyComponent = soldier.get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
	var formation_position: Vector2 = to_formation_position(center_global_position, soldier_count, soldier_index)
	soldier_rally_c.new_rally_global_position(soldier, formation_position, is_forced, center_global_position, false)
	
	var melee_c: MeleeComponent = soldier.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if melee_c:
		melee_c.original_global_position = formation_position


## 将位置转换为阵型位置。
func to_formation_position(center_position: Vector2, count: int, index: int) -> Vector2:
	if count == 1:
		return center_position
		
	var angle_step: float = 2 * PI / count
	var angle: float = (index - 1) * angle_step - Constants.HALF_PI
	
	return MathUtils.get_point_on_ellipse(center_position, config.rally_radius, angle)
