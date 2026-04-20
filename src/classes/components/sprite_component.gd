@tool
extends Node2D
class_name SpriteComponent

@export_group("Sync Animation")
## 是否所有者同步播放动画
@export var sync_source: bool = false
## 同步动画数据
@export var sync_animations: SyncAnimationsData = null

## 精灵列表
var list: Array[Node2D] = []
## 精灵组列表
var group_list: Array[SpriteGroup] = []


func _ready() -> void:
	for child: Node in get_children():
		if child is SpriteGroup:
			for sprite: Node2D in child.get_children():
				list.append(sprite)
				
			group_list.append(child)
		else:
			list.append(child)


func _get_configuration_warnings() -> PackedStringArray:
	if not get_children():
		return ["请至少增加一个 AnimatedSprite2D、Sprite2D、SpriteGroup 节点"]
		
	return []
