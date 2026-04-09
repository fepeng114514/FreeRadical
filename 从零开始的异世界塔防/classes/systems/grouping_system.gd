extends System
class_name GroupingSystem
## 分组系统
##
## 实时分组将实体分组到 [EntityMgr]，以便于根据分组快速获取实体，同时将实体根据坐标插入到可接受的空间索引中以便于根据坐标快速获取实体。


var space_index_grid_size: float = EntityMgr.SPACE_INDEX_GRID_SIZE
var space_index_grids: Array[Dictionary] = []
var world_size := Vector2i.ZERO
var component_groups: Dictionary[String, Array] = {}
var type_groups: Dictionary[String, Array] = {}


func _ready() -> void:
	space_index_grids = EntityMgr.space_index_grids
	world_size = GlobalMgr.world_size
	component_groups = EntityMgr.component_groups
	type_groups = EntityMgr.type_groups


func _on_update(_delta: float) -> void:
	# 清空空间索引网格
	for grid_col: Dictionary in space_index_grids:
		for key: String in grid_col:
			if key.begins_with("has_"):
				grid_col[key] = false

		for grid_row: Dictionary in grid_col.row:
			for type_group: Array in grid_row.values():
				type_group.clear()

	# 清空分组
	for group_name: String in component_groups:
		component_groups[group_name].clear()

	for group_name: String in type_groups:
		type_groups[group_name].clear()

	for e: Entity in EntityMgr.get_valid_entities():
		# 根据实体的坐标将实体插入到空间索引中
		var x: int = ceil(e.position.x / space_index_grid_size)
		var y: int = ceil(e.position.y / space_index_grid_size)

		var grid_col: Dictionary = space_index_grids[x]
		var grid_row: Dictionary = grid_col.row[y]
		grid_row.entities.append(e)
		grid_col.has_entities = true

		# 根据实体的标识和组件将实体分组
		if e.flag_bits != 0:
			for flags: C.Flag in C.FLAG_TO_GROUP_KEYS:
				if e.flag_bits & flags:
					var group_name: StringName = C.FLAG_TO_GROUP[flags]

					type_groups[group_name].append(e)
					grid_row[group_name].append(e)
					grid_col["has_" + group_name] = true

		for c_name: String in e.components:
			if not component_groups.has(c_name):
				component_groups[c_name] = []

			component_groups[c_name].append(e)
