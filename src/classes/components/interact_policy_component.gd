@tool
extends Component
class_name InteractPolicyComponent
## 交互策略组件。
##
## [InteractPolicyComponent] 用于定义实体的交互策略。


## 阵营枚举。
enum Faction {
	## 阵营: 无。
	NONE = 1,
	## 阵营: 敌人。
	ENEMY = 1 << 1,
	## 阵营: 友军。
	FRIENDLY = 1 << 2,
}


## 实体类型枚举。
enum EntityType {
	## 实体类型: 无。
	NONE = 0,
	## 实体类型: 单位。
	UNIT = 1,
	## 实体类型: 防御塔。
	TOWER = 1 << 1,
	## 实体类型: 单位和防御塔。
	UNIT_AND_TOWER = UNIT | TOWER,
}


## 实体标识枚举。
enum EntityFlag {
	## 实体标识: 无。
	NONE = 0,
	## 实体标识: BOSS。
	BOSS = 1,
	## 实体标识: 英雄。
	HERO = 1 << 1,
	## 实体标识: 飞行。
	FLYING = 1 << 2,
}


## 配置。
@export var config: InteractPolicyComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()


## 是否双方策略任意一方的实体标识被另一方禁止交互。
func is_entity_flag_banned_either(other: InteractPolicyComponent) -> bool:
	var other_config = other.config
	return config.entity_flag_bans & other_config.entity_flags or other_config.entity_flag_bans & config.entity_flags


## 是否场景路径被当前策略禁止交互。
func is_scene_banned(scene_path: String) -> bool:
	if config.scene_path_bans.has(scene_path):
		return true
	
	var scene_path_allows: PackedStringArray = config.scene_path_allows
	if scene_path_allows and not scene_path_allows.has(scene_path):
		return true
		
	return false


## 是否双方场景路径被任意一方策略禁止交互。
func is_scene_banned_either(other: InteractPolicyComponent, scene_path: String, other_scene_path: String) -> bool:
	return is_scene_banned(other_scene_path) or other.is_scene_banned(scene_path)


## 是否双方策略任意一方的实体标识或场景路径被另一方禁止交互。
func is_banned_either(other: InteractPolicyComponent, scene_path: String, other_scene_path: String) -> bool:
	if is_entity_flag_banned_either(other):
		return true

	if is_scene_banned_either(other, scene_path, other_scene_path):
		return true

	return false
