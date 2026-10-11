@tool
extends Resource
class_name InteractPolicy 
## 交互策略类。
##
## 交互策略用于定义实体之间的交互规则，包括禁止交互的实体标识、修改器类型、光环类型等。


## 标识枚举。
enum Flag {
	## 标识: 无。
	NONE = 0,
	## 标识: 敌人。
	ENEMY = 1,
	## 标识: BOSS。
	BOSS = 1 << 1,
	## 标识: 友军。
	FRIENDLY = 1 << 2,
	## 标识: 单位。
	UNIT = ENEMY | FRIENDLY,
	## 标识: 英雄。
	HERO = 1 << 3,
	## 标识: 防御塔。
	TOWER = 1 << 4,
	## 标识: 修改器。
	MODIFIER = 1 << 5,
	## 标识: 光环。
	AURA = 1 << 6,
	## 标识: 飞行。
	FLYING = 1 << 7,
	
	## 标识: 远程。
	RANGED = 1 << 20,
	## 标识: 近战。
	MELEE = 1 << 21,
}


## 实体自身的标识。
@export var flags: int = 0: 
	set(v):
		flags = v
		emit_changed()
## 禁止交互的实体标识。
@export var bans: int = 0
## 修改器类型。
@export var mod_type_flags: int = 0
## 禁止的修改器类型。
@export var mod_type_bans: int = 0
## 光环类型。
@export var aura_type_flags: int = 0
## 禁止的光环类型。
@export var aura_type_bans: int = 0
## 白名单场景名称。
@export_file("*.tscn") var whitelist: PackedStringArray
## 黑名单场景名称。
@export_file("*.tscn") var blacklist: PackedStringArray


func _init() -> void:
	resource_local_to_scene = true


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"flags":
			property.hint_string = "mask_check(%s)" % Flag
		"bans":
			property.hint_string = "mask_check(%s)" % Flag
		"mod_type_flags":
			property.hint_string = "mask_check(%s)" % ModifierComponent.Type
		"aura_type_flags":
			property.hint_string = "mask_check(%s)" % AuraComponent.Type
		"mod_type_bans":
			property.hint_string = "mask_check(%s)" % ModifierComponent.Type
		"aura_type_bans":
			property.hint_string = "mask_check(%s)" % AuraComponent.Type


## 检查是否与另一个策略禁止交互。
func is_mutual_banned(other: InteractPolicy) -> bool:
	return other.flags & bans or flags & other.bans


## 检查是否与另一个策略单向禁止交互。
func is_banned(other: InteractPolicy) -> bool:
	return other.flags & bans


## 检查是否与另一个策略禁止修改器类型。
func is_mutual_mod_type_banned(other: InteractPolicy) -> bool:
	return other.mod_type_flags & mod_type_bans or mod_type_flags & other.mod_type_bans


## 检查是否与另一个策略单向禁止修改器类型。
func is_mod_type_banned(other: InteractPolicy) -> bool:
	return other.mod_type_flags & mod_type_bans


## 检查是否与另一个策略禁止光环类型。
func is_mutual_aura_type_banned(other: InteractPolicy) -> bool:
	return other.aura_type_flags & aura_type_bans or aura_type_flags & other.aura_type_bans


## 检查是否与另一个策略单向禁止光环类型。
func is_aura_type_banned(other: InteractPolicy) -> bool:
	return other.aura_type_flags & aura_type_bans


## 检查是否允许与另一个场景名称的实体交互。
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


## 检查是否允许与另一个场景名称的实体单向交互。
func is_scene_allowed(other_scene_name: StringName) -> bool:
	# 没有在黑名单中
	if blacklist.has(other_scene_name):
		return false
	
	# 在白名单中
	if whitelist:
		return whitelist.has(other_scene_name)
		
	return true


## 检查是否允许一个实体与目标实体交互。
static func is_allowed_target(entity: Entity, target: Entity, interact_p: InteractPolicy, t_interact_p: InteractPolicy) -> bool:
	if not interact_p or not t_interact_p:
		return true

	if (
			interact_p.is_mutual_banned(t_interact_p) 
			or not interact_p.is_mutual_scene_allowed(t_interact_p, entity.scene_name, target.scene_name)
		):
			return false

	return true
