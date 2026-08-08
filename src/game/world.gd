@tool
extends Node2D
## 世界类。
##
## 实体通常会挂载到该节点下。


func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		SystemMgr.append_insert_queue.connect(_on_append_insert_queue)
		
		for e: Entity in get_children():
			EntityMgr.setup_entity(e)
				
			e.insert_entity()
			

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not get_children():
		warnings.append("请至少增加一个 WaveSpawner 子节点，否则无法生成敌人。")
		
	return warnings
	

func _on_append_insert_queue(entity: Entity) -> void:
	if entity.get_parent() != null:
		return
		
	add_child(entity)
