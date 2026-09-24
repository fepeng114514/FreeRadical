@tool
extends Node2D
class_name ECSEntity
## 实体基类。
##
## 实体用于存储组件，并提供组件的访问接口，以及实体状态的管理。


## 实体属于的实体组。[br]
## 实体可以属于多个实体组，每个实体组都有一个唯一的名称。[br]
## 实体组用于将实体分类，方便后续的查询和管理。
@export var entity_groups: Array[StringName] = []

## 实体场景名称
var scene_name: String = ""
## 实体本地化名称
var localization_key: String = ""
## 实体唯一 ID
var id: int = Constants.UNSET

## 实体位于有效实体数组的索引。
var valid_entities_index: int = Constants.UNSET

## 上次位于空间哈希的单元格索引。
var last_space_hash_cell_index: int = Constants.UNSET

## 上次位于空间哈希单元格的实体索引。
var last_space_hash_cell_entities_index: int = Constants.UNSET
## 当前位于空间哈希单元格的实体索引。
var space_hash_cell_entities_index: int = Constants.UNSET

## 上次位于空间哈希单元格的实体组的索引。
var last_space_hash_cell_entity_groups_indexes: Dictionary[StringName, int] = {}
## 当前位于空间哈希单元格的实体组的索引。
var space_hash_cell_entity_groups_indexes: Dictionary[StringName, int] = {}

## 上次位于空间哈希单元格的组件实体组的索引。
var last_space_hash_cell_component_entity_groups_indexes: Dictionary[StringName, int] = {}
## 当前位于空间哈希单元格的组件实体组的索引。
var space_hash_cell_component_entity_groups_indexes: Dictionary[StringName, int] = {}

## 实体属于的实体组是否发生变化。
var is_entity_groups_changed: bool = false
## 上次实体属于的实体组。
var last_entity_groups: Array[StringName] = []
## 上次位于实体组的索引。
var last_entity_groups_indexes: Dictionary[StringName, int] = {}
## 当前位于实体组的索引。
var entity_groups_indexes: Dictionary[StringName, int] = {}

## 拥有的所有组件节点引用
var components: Dictionary[StringName, ECSComponent] = {}
## 拥有的所有组件名称。
var component_names: Array[StringName] = []
## 组件是否发生变化。
var is_component_changed: bool = false
## 上次实体拥有的所有组件名称。
var last_component_names: Array[StringName] = []
## 上次位于组件实体组的索引。
var last_component_entity_groups_indexes: Dictionary[StringName, int] = {}
## 当前位于组件实体组的索引。
var component_entity_groups_indexes: Dictionary[StringName, int] = {}


func _ready() -> void:
	scene_name = scene_file_path.get_file().get_basename()
	localization_key = scene_name.to_upper()

	for child: Node in get_children():
		if not child is Component:
			continue

		var node_script: GDScript = child.get_script()
		var node_class_name: StringName = node_script.get_global_name()
			
		components[node_class_name] = child
		component_names.append(node_class_name)


func _validate_property(property: Dictionary) -> void:
	if property.name == "entity_groups":
		var options: String = ",".join(ECSSettingManager.get_setting().entity_groups)
		property.hint = PROPERTY_HINT_TYPE_STRING
		property.hint_string = "%d/%d:%s" % [TYPE_STRING, PROPERTY_HINT_ENUM, options]


## 获取本土化名称
func get_localized_name() -> String:
	return tr(scene_name.to_upper())
	
	
## 设置实体组。
func set_entity_groups(groups: Array[StringName], set_changed_state_enabled: bool = true) -> void:
	last_entity_groups = entity_groups
	entity_groups = groups
	if set_changed_state_enabled:
		is_entity_groups_changed = true


## 增加实体组件。
func add_component(component: ECSComponent) -> void:
	last_component_names = component_names

	var component_class_name: StringName = component.get_class()
	components[component_class_name] = component

	component_names = components.keys()
	is_component_changed = true


## 移除实体组件。
func remove_component(component: ECSComponent) -> void:
	last_component_names = component_names

	var component_class_name: StringName = component.get_class()
	components.erase(component_class_name)

	component_names = components.keys()
	is_component_changed = true
