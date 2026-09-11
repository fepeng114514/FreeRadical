@tool
extends Resource
class_name ECSSetting


@export_group("Spatial Hash")
## 空间哈希单元格大小。
@export var spatial_hash_cell_size: int = 100
## 空间哈希的网格行数。
@export var spatial_hash_row_count: int = 26
## 空间哈希的网格列数。
@export var spatial_hash_column_count: int = 15
## 是否启用自扩容空间哈希网格，当网格不存在时自动扩容，这会禁用手动设置网格行列数。
@export var auto_expand_spatial_hash_grid_enable: bool = false:
	set(v):
		auto_expand_spatial_hash_grid_enable = v
		notify_property_list_changed()


@export_group("Entity")
## 实体分组列表。
@export var entity_groups: Array[StringName] = []


func _validate_property(property: Dictionary):
	match property.name:
		"spatial_hash_row_count":
			if auto_expand_spatial_hash_grid_enable:
				property.usage = PROPERTY_USAGE_NONE
		"spatial_hash_column_count":
			if auto_expand_spatial_hash_grid_enable:
				property.usage = PROPERTY_USAGE_NONE
