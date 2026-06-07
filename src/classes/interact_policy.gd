@tool
extends Resource
class_name InteractPolicy 
## 交互策略
##
## 交互策略用于定义实体之间的交互规则，包括禁止交互的实体标识、状态效果类型、光环类型等。


## 实体自身的标识（位标志）
@export var flags: int = 0
## 禁止交互的实体标识（位标志）
@export var bans: int = 0
## 状态效果类型
@export var mod_type_flags: int = 0
## 禁止的状态效果类型
@export var mod_type_bans: int = 0
## 光环类型
@export var aura_type_flags: int = 0
## 禁止的光环类型
@export var aura_type_bans: int = 0
## 白名单场景名称
@export var whitelist: PackedStringArray = []
## 黑名单场景名称
@export var blacklist: PackedStringArray = []


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"flags":
			property.hint_string = "mask_enum:Flag"
		"bans":
			property.hint_string = "mask_enum:Flag"
		"mod_type_flags":
			property.hint_string = "mask_enum:ModType"
		"aura_type_flags":
			property.hint_string = "mask_enum:AuraType"
		"mod_type_bans":
			property.hint_string = "mask_enum:ModType"
		"aura_type_bans":
			property.hint_string = "mask_enum:AuraType"


## 检查是否与另一个策略禁止交互
func is_mutual_banned(other: InteractPolicy) -> bool:
	return other.flags & bans or flags & other.bans


## 检查是否与另一个策略单向禁止交互
func is_banned(other: InteractPolicy) -> bool:
	return other.flags & bans


## 检查是否与另一个策略禁止状态效果类型
func is_mutual_mod_type_banned(other: InteractPolicy) -> bool:
	return other.mod_type_flags & mod_type_bans or mod_type_flags & other.mod_type_bans


## 检查是否与另一个策略单向禁止状态效果类型
func is_mod_type_banned(other: InteractPolicy) -> bool:
	return other.mod_type_flags & mod_type_bans


## 检查是否与另一个策略禁止光环类型
func is_mutual_aura_type_banned(other: InteractPolicy) -> bool:
	return other.aura_type_flags & aura_type_bans or aura_type_flags & other.aura_type_bans


## 检查是否与另一个策略单向禁止光环类型
func is_aura_type_banned(other: InteractPolicy) -> bool:
	return other.aura_type_flags & aura_type_bans


## 检查是否允许与另一个场景名称的实体交互
func is_mutual_scene_allowed(other: InteractPolicy, scene_name: StringName, other_scene_name: StringName) -> bool:
	# 没有在双方的黑名单中
	if blacklist.has(other_scene_name) or other.blacklist.has(scene_name):
		return false
	
	# 在双方的白名单中
	if whitelist and other.whitelist:
		return whitelist.has(other_scene_name) and other.whitelist.has(scene_name)
	else:
		if whitelist:
			return whitelist.has(other_scene_name)
			
		if other.whitelist:
			return other.whitelist.has(scene_name)
		
	return true


## 检查是否允许与另一个场景名称的实体单向交互
func is_scene_allowed(other_scene_name: StringName) -> bool:
	# 没有在黑名单中
	if blacklist.has(other_scene_name):
		return false
	
	# 在白名单中
	if whitelist:
		return whitelist.has(other_scene_name)
		
	return true


static func is_allowed_target(e: Entity, target: Entity, interact_p: InteractPolicy, t_interact_p: InteractPolicy) -> bool:
	if not interact_p or not t_interact_p:
		return true

	if (
			interact_p.is_mutual_banned(t_interact_p) 
			or not interact_p.is_mutual_scene_allowed(t_interact_p, e.scene_name, target.scene_name)
		):
			return false

	return true
