extends PanelContainer

@export_group("Node Ref")
@export var entity_name: Label = null
@export var hp_label: Label = null
@export var hp_value: Label = null
@export var melee_type_icon: TextureRect = null
@export var melee_value: Label = null
@export var ranged_type_icon: TextureRect = null
@export var ranged_value: Label = null
@export var phys_armor_icon: TextureRect = null
@export var phys_armor_value: Label = null
@export var magic_armor_icon: TextureRect = null
@export var magic_armor_value: Label = null

## 当前选择的实体
var selected_entity: Entity = null
## 显示类型
var info_bar_type: SelectComponent.InfoBarType = SelectComponent.InfoBarType.UNIT

@onready var all_controls: Array[Control] = [
	hp_label, 
	hp_value, 
	melee_type_icon, 
	melee_value, 
	ranged_type_icon, 
	ranged_value, 
	phys_armor_icon, 
	phys_armor_value, 
	magic_armor_icon, 
	magic_armor_value,
]
## 信息栏对应信息类型显示配置
@onready var show_configs: Dictionary[SelectComponent.InfoBarType, Array] = {
	SelectComponent.InfoBarType.UNIT: [
		hp_label,
		hp_value,
		melee_type_icon,
		melee_value,
		ranged_type_icon,
		ranged_value,
		phys_armor_icon,
		phys_armor_value,
		magic_armor_icon,
		magic_armor_value,
	],
	SelectComponent.InfoBarType.TOWER: [
		ranged_type_icon,
		ranged_value,
	],
}


func _ready() -> void:
	SelectManager.entity_selected.connect(_show)
	SelectManager.entity_deselected.connect(_hide)
	visible = false


func _process(_delta: float) -> void:
	if not selected_entity:
		_hide()
		return
	
	if info_bar_type == SelectComponent.InfoBarType.NONE:
		return
		
	entity_name.text = selected_entity.name

	for control: Control in all_controls:
		control.visible = false
	
	var show_config: Array = show_configs[info_bar_type]
	for control: Control in show_config:
		control.visible = true

	match info_bar_type:
		SelectComponent.InfoBarType.UNIT:
			_update_unit_info()
		SelectComponent.InfoBarType.TOWER:
			if selected_entity.get_node_or_null(Constants.TOWER_COMPONENT_NODE_PATH):
				_update_tower_info()
	
	
## 显示信息栏
func _show(entity: Entity) -> void:
	if entity == selected_entity:
		return
		
	_hide()
	
	var select_c: SelectComponent = entity.get_node_or_null(Constants.SELECT_COMPONENT_NODE_PATH)
		
	selected_entity = entity
	info_bar_type = select_c.config.info_bar_type
	
	if info_bar_type == SelectComponent.InfoBarType.NONE:
		return
		
	visible = true

	
## 隐藏信息栏
func _hide() -> void:
	visible = false
	selected_entity = null


## 更新单位信息
func _update_unit_info() -> void:
	var health_c: HealthComponent = selected_entity.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	var health_c_config: HealthComponentNodeConfig = health_c.config
	hp_value.text = "%d/%d" % [health_c_config.hp_max, health_c.hp]
	phys_armor_value.text = "%d" % (health_c_config.physical_armor * 100)
	magic_armor_value.text = "%d" % (health_c_config.magical_armor * 100)
	
	var melee_c: MeleeComponent = selected_entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if melee_c and melee_c.get_child(0):
		_set_melee_value(melee_c)
	else:
		_hide_melee_info()
		
	var skill_c: SkillComponent = selected_entity.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
	if skill_c:
		_set_ranged_value(skill_c)
	else:
		_hide_ranged_info()


## 更新防御塔信息
func _update_tower_info() -> void:
	var tower_c: TowerComponent = selected_entity.get_node_or_null(Constants.TOWER_COMPONENT_NODE_PATH)

	if tower_c.get_child_count() == 0:
		var skill_c: SkillComponent = selected_entity.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
		if skill_c:
			_set_ranged_value(skill_c)
		else:
			_hide_ranged_info()
	else:
		var first_entity: Entity = tower_c.get_child(0)
		var skill_c: SkillComponent = first_entity.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
		if skill_c:
			_set_ranged_value(skill_c)
		else:
			_hide_ranged_info()


func _hide_ranged_info() -> void:
	ranged_type_icon.visible = false
	ranged_value.visible = false


func _set_ranged_value(skill_c: SkillComponent) -> void:
	var first_ranged_skill := skill_c.get_child(0) as RangedSkill
	if not first_ranged_skill:
		_hide_ranged_info()
		return

	var bullet_template: NodeConfigTemplateNode = NodeConfigManager.get_node_config_template_by_entity_uid(first_ranged_skill.config.bullet_scene)
	var bullet_c_config: BulletComponentNodeConfig = bullet_template.get_node_config(Constants.BULLET_COMPONENT_NODE_PATH)
	var damage_influence := bullet_c_config.influence as DamageInfluence
	if damage_influence:
		ranged_value.text = "%d-%d/%.1f" % [damage_influence.min_value, damage_influence.max_value, first_ranged_skill.config.cooldown]
	else:
		_hide_ranged_info()
	

func _hide_melee_info() -> void:
	melee_type_icon.visible = false
	melee_value.visible = false

	
func _set_melee_value(melee_c: MeleeComponent) -> void:
	var first_melee_skill := melee_c.get_child(0) as MeleeSkill
	if not first_melee_skill:
		_hide_melee_info()
		return
		
	var damage_influence := first_melee_skill.config.influence as DamageInfluence
	if damage_influence:
		melee_value.text = "%d-%d/%.1f" % [damage_influence.min_value, damage_influence.max_value, first_melee_skill.config.cooldown]
	else:
		_hide_melee_info()
