@tool
extends Node2D
class_name Entity
## 实体节点。
##
## [Entity] 用于表示游戏中所有具有行为和属性的对象，例如: 敌人、友军、防御塔、子弹、修改器等。通过各种 [Component] 来实现实体的行为和属性。


@warning_ignore_start("unused_signal")
## 实体移除信号，当实体准备从场景中移除时触发。
signal entity_removing
@warning_ignore_restore("unused_signal")


## 实体状态枚举。
enum State {
	## 实体状态：空闲。
	IDLE = 1,
	## 实体状态：拦截敌人中。
	MELEE = 1 << 1,
	## 实体状态：释放远程技能中。
	RANGED = 1 << 2,
	## 实体状态：前往集结点。
	RALLY = 1 << 3,
	## 实体状态：在路径上移动。
	NAV_PATH_WALK = 1 << 4,
	## 实体状态：闪避。
	DODGE = 1 << 5,

	## 实体状态：死亡。
	DEAD = 1 << 10,

	## 实体状态：被禁止。
	DISABLED = 1 << 20,
	## 实体状态：被移除。
	REMOVED = 1 << 21,
	## 实体状态：阻塞中。
	BLOCKING = 1 << 22,
	## 实体状态：等待中。
	WAITING = 1 << 23,
	## 实体状态：中断等待。
	INTERRUPT_WAIT = 1 << 24,
}


## 实体元状态枚举。
enum MetaState {
	## 实体元状态：无。
	NONE = 0,
	## 实体元状态：首次更新。
	FIRST_UPDATE = 1,
	## 实体元状态：注定死亡。
	DOOMED = 1 << 1,
}


## 来源类型枚举。
enum SourceType {
	## 来源类型：无
	NONE,
	## 来源类型：防御塔射手
	TOWER_SHOOTER,
	## 来源类型：兵营
	BARRACK_SOLDIER,
}


#region 属性
## 更新节点配置模板按钮。
@export_tool_button("更新节点配置模板") var update_config_template: Callable = _update_config_template
## 节点配置模板。
@export var node_config_template: NodeConfigTemplateNode = null:
	set(v):
		node_config_template = v
		update_configuration_warnings()

## 实体场景名称。
var scene_name: String = ""
## 场景 UID。
var scene_file_uid: String = ""
## 实体本地化名称。
var localization_key: String = ""
## 实体唯一 ID。
var id: int = Constants.UNSET
## 所有者或来源 ID。
var source_id: int = Constants.UNSET
## 来源类型。
var source_type: SourceType = SourceType.NONE
## 拥有的修改器 ID 列表。
var has_modifier_ids := PackedInt32Array()
## 拥有的修改器 ID 列表是否变化。
var is_modifier_ids_changed: bool = false
## 拥有的光环 ID 列表。
var has_aura_ids := PackedInt32Array()
## 以此实体为目标的子弹 ID 列表。
var aimed_bullet_ids := PackedInt32Array()
## 是否有新的子弹以此实体为目标。
var has_new_aimed_bullet: bool = false
## 状态。
var state: int = Entity.State.IDLE
## 元状态。
var meta_state: int = Entity.MetaState.FIRST_UPDATE
## 面朝的全局位置。
var facing_global_position := Vector2.INF
#endregion


func _ready() -> void:
	scene_name = scene_file_path.get_file().get_basename()
	scene_file_uid = ResourceUID.path_to_uid(scene_file_path)
	localization_key = scene_name.to_upper()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
		
	if EditorInterface.get_edited_scene_root() == self:
		if node_config_template:
			if not FileAccess.file_exists(node_config_template.resource_path):
				warnings.append("请将 node_config_template 节点配置模板保存为文件，否则后续无法在节点配置管理器中索引该实体的节点配置模板。")
		else:
			warnings.append("请设置一个 node_config_template 节点配置模板，或点击实体的 “更新节点配置模板” 按钮一键生成。")

	return warnings


func _to_string():
	return String(name)


## 获取本土化名称。
func get_localized_name() -> String:
	return tr(localization_key)


#region 组件相关方法
## 增加组件。
func add_component(component: Component) -> void:
	add_child(component)


## 在帧末尾移除组件。
func queue_free_component(component: Component) -> void:
	component.queue_free()
#endregion


#region 实体相关方法
## 设置实体全局位置，根据拥有的组件智能赋值。
func set_global_position_with_components(new_global_position: Vector2) -> void:
	global_position = new_global_position
	
	var rally_c: RallyComponent = get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
	if rally_c:
		rally_c.new_rally_global_position(self, new_global_position)
	
	var nav_path_c: NavPathComponent = get_node_or_null(Constants.NAV_PATH_COMPONENT_NODE_PATH)
	if nav_path_c:
		nav_path_c.set_nav_path_to_nearest_node(self, new_global_position)


func is_waiting() -> bool:
	return state & (Entity.State.BLOCKING | Entity.State.WAITING | Entity.State.DISABLED)


## 协程等待指定时长。[br][br]
## [param break_fn]: 中断函数。返回 [code]true[/code] 表示中断等待。
## -> 等待是否被中断。
func y_wait(time: float = 0.0, break_fn: Callable = Callable()) -> bool:
	state |= Entity.State.WAITING

	Log.verbose("实体等待: %s, %.2fs" % [self, time])
	if time <= 0:
		return false

	var wait_timestamp: float = TimeManager.tick_timestamp
	var is_break: bool = false
	while not TimeManager.has_elapsed(wait_timestamp, time):
		is_break = (
			not is_inside_tree()
			or state & Entity.State.INTERRUPT_WAIT 
			or break_fn.is_valid() and break_fn.call()
		)
		if is_break:
			Log.verbose("%s 中断等待: %.2fs" % [self, time])
			break

		await get_tree().process_frame

	Log.verbose("实体等待完毕: %s, %.2fs" % [self, time])

	state &= ~(Entity.State.WAITING | Entity.State.INTERRUPT_WAIT)
	return is_break
#endregion

		
func _update_config_template() -> void:
	var scene_file_dir: String = scene_file_path.get_base_dir()
	var template_dir: String = scene_file_dir.path_join("template")
	DirAccess.make_dir_absolute(template_dir)

	var new_config_template := NodeConfigTemplateNode.new()
	_build_config_template_node_recursive(self, new_config_template, template_dir)

	var root_save_path: String = template_dir.path_join("node_config_template.tres")
	node_config_template = Utils.save_and_load_resource(new_config_template, root_save_path)
	Log.info("生成配置模板: %s" % root_save_path)
	EditorInterface.mark_scene_as_unsaved()


func _build_config_template_node_recursive(node: Node, current_config_template_parent: NodeConfigTemplateNode, template_dir: String) -> void:
	for child: Node in node.get_children():
		if child is Entity:
			continue

		var config_prop: Dictionary = {}
		for prop: Dictionary in child.get_property_list():
			if prop.name != "config":
				continue

			config_prop = prop
			break

		if config_prop.is_empty():
			continue
		
		var node_name: String = child.name
		var node_path: NodePath = get_path_to(child)
		var save_dir: String = template_dir.path_join(String(node_path).to_snake_case()).simplify_path()
		DirAccess.make_dir_absolute(save_dir)

		var config_template_node := NodeConfigTemplateNode.new()
		config_template_node.name = node_name
		
		if child.config:
			config_template_node.config = child.config
		else:
			var cls_name: StringName = config_prop.class_name
			var cls: Dictionary = GlobalManager.global_classes[cls_name]
			var new_config: NodeConfig = load(cls.path).new()
			
			var save_path: String = save_dir.path_join("%s.tres" % node_name.to_snake_case())
			new_config = Utils.save_and_load_resource(new_config, save_path)
			child.config = new_config
			config_template_node.config = new_config
			Log.verbose("创建配置: %s" % save_path)

		current_config_template_parent.add_child(config_template_node)
		_build_config_template_node_recursive(child, config_template_node, template_dir)
