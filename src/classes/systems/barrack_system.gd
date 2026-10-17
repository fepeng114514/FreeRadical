extends System
class_name BarrackSystem
## 兵营系统。
##
## [BarrackSystem] 负责处理拥有 [BarrackComponent] 的实体。


func _on_update(_delta: float) -> void:
	for barrack: Entity in EntityManager.get_component_entity_group(Enums.ComponentFlag.BARRACK):
		var barrack_c: BarrackComponent = barrack.get_node_or_null(Constants.BARRACK_COMPONENT_NODE_PATH)
		if not barrack_c.need_reset_rally_center_global_position:
			continue

		barrack_c.need_reset_rally_center_global_position = false
		
		var barrack_record: BarrackRecord = barrack.get_node_or_null(Constants.BARRACK_RECORD_NODE_PATH)
		var soldier_ids: PackedInt32Array = barrack_record.soldier_ids
		var soldier_ids_size: int = barrack_record.soldier_ids.size()
		for soldier_index: int in soldier_ids_size:
			var soldier: Entity = EntityManager.get_entity_by_id(soldier_ids[soldier_index])
			barrack_c.set_rally_center_global_position(barrack_record.rally_center_global_position, soldier, soldier_index, soldier_ids_size)
	
