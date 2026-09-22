@tool
extends SearchSkillNodeConfig
class_name SpawnSkillNodeConfig
## 生成实体技能节点配置资源。


## 生成的实体场景名称数组。
@export_file("*.tscn") var spawns: PackedStringArray
## 生成的实体初始位置偏移组。
@export var spawn_offsets: OffsetGroup = null:
	set(v):
		spawn_offsets = v
		emit_changed()