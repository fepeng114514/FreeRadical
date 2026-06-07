extends System
class_name GroupingSystem
## 分组系统。
##
## 负责实时实体分组到 [EntityMgr]，以便于根据分组快速获取实体，同时将实体根据坐标插入到空间索引数组中以便于根据坐标快速获取实体。


## 根据标识分到哪组的字典。
const FLAG_TO_GROUP: Dictionary[C.Flag, StringName] = {
	C.Flag.ENEMY: C.GROUP_ENEMIES,
	C.Flag.FRIENDLY: C.GROUP_FRIENDLYS,
	C.Flag.UNIT: C.GROUP_UNIT,
	C.Flag.TOWER: C.GROUP_TOWERS,
	C.Flag.MODIFIER: C.GROUP_MODIFIERS,
	C.Flag.AURA: C.GROUP_AURAS,
}

## 根据标识分到哪组的字典键。
const FLAG_TO_GROUP_KEYS: Array[C.Flag] = [
	C.Flag.ENEMY,
	C.Flag.FRIENDLY,
	C.Flag.UNIT,
	C.Flag.TOWER,
	C.Flag.MODIFIER,
	C.Flag.AURA,
]


func _on_update(_delta: float) -> void:
	var space_index_grid_list: Array[Dictionary] = SearchMgr.space_index_grid_list

	# 清空空间索引网格
	for grid_col: Dictionary in space_index_grid_list:
		for key: String in grid_col:
			if key.begins_with("has_"):
				grid_col[key] = false

		for grid_row: Dictionary in grid_col.row:
			for type_group: Array in grid_row.values():
				type_group.clear()

	var component_group_list: Dictionary[String, Array] = EntityMgr.component_group_list
	var type_group_list: Dictionary[String, Array] = EntityMgr.type_group_list

	# 清空分组
	for group_name: String in component_group_list:
		component_group_list[group_name].clear()

	for group_name: String in type_group_list:
		type_group_list[group_name].clear()

	var space_index_grid_size: float = SearchMgr.SPACE_INDEX_GRID_SIZE
	var space_index_grid_count_x: int = SearchMgr.space_index_grid_count_x
	var space_index_grid_count_y: int = SearchMgr.space_index_grid_count_y

	for e: Entity in EntityMgr.get_valid_entities():
		var e_global_position: Vector2 = e.global_position
		
		# 根据实体的坐标将实体插入到空间索引中
		var x: int = floori(e_global_position.x / space_index_grid_size)
		var y: int = floori(e_global_position.y / space_index_grid_size)

		if x >= space_index_grid_count_x:
			continue
			
		if y >= space_index_grid_count_y:
			continue

		var grid_col: Dictionary = space_index_grid_list[x]
		var grid_row: Dictionary = grid_col.row[y]
		grid_row.entities.append(e)
		grid_col.has_entities = true

		# 根据实体的标识和组件将实体分组
		var interact_p: InteractPolicy = e.interact_policy
		if interact_p:
			for flags: C.Flag in FLAG_TO_GROUP_KEYS:
				if not interact_p.flags & flags:
					continue

				var group_name: StringName = FLAG_TO_GROUP[flags]

				type_group_list[group_name].append(e)
				grid_row[group_name].append(e)
				grid_col["has_" + group_name] = true

		for c_name: String in e.components:
			if not component_group_list.has(c_name):
				component_group_list[c_name] = []

			component_group_list[c_name].append(e)
