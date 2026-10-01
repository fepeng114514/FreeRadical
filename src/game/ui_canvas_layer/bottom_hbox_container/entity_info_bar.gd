extends PanelContainer

@export_group("NodeRef")
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

## 信息栏对应信息类型显示配置
@onready var show_config: Dictionary[SelectComponent.InfoBarType, Dictionary] = {
	SelectComponent.InfoBarType.UNIT: {
		"hp_label": true,
		"hp_value": true,
		"melee_type_icon": true,
		"melee_value": true,
		"ranged_type_icon": true,
		"ranged_value": true,
		"phys_armor_icon": true,
		"phys_armor_value": true,
		"magic_armor_icon": true,
		"magic_armor_value": true,
	},
	SelectComponent.InfoBarType.TOWER: {
		"hp_label": false,
		"hp_value": false,
		"melee_type_icon": false,
		"melee_value": false,
		"ranged_type_icon": true,
		"ranged_value": true,
		"phys_armor_icon": false,
		"phys_armor_value": false,
		"magic_armor_icon": false,
		"magic_armor_value": false,
	}
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
	
	var current_configs: Dictionary = show_config[info_bar_type]
	for control_name: String in current_configs:
		var control: Control = get(control_name)
		var is_hidden: bool = current_configs[control_name]
		control.visible = is_hidden

	match info_bar_type:
		SelectComponent.InfoBarType.UNIT:
			_update_unit_info()
		SelectComponent.InfoBarType.TOWER:
			if selected_entity.get_node_or_null(Constants.CN_TOWER):
				_update_tower_info()
	
	
## 显示信息栏
func _show(entity: Entity) -> void:
	if entity == selected_entity:
		return
		
	_hide()
	
	var select_c: SelectComponent = entity.get_node_or_null(Constants.CN_SELECT)
		
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
	var health_c: HealthComponent = selected_entity.get_node_or_null(Constants.CN_HEALTH)
	hp_value.text = "%d/%d" % [health_c.config.hp_max, health_c.hp]
	phys_armor_value.text = "%d" % (health_c.config.physical_armor * 100)
	magic_armor_value.text = "%d" % (health_c.config.magical_armor * 100)
	
	var melee_c: MeleeComponent = selected_entity.get_node_or_null(Constants.CN_MELEE)
	if melee_c and melee_c.get_child(0):
		_set_value_melee(melee_c)
	else:
		melee_value.visible = false
		melee_type_icon.visible = false
		
	var skill_c: SkillComponent = selected_entity.get_node_or_null(Constants.CN_SKILL)
	
	if skill_c:
		if skill_c.get_child(0) as RangedSkill:
			_set_value_ranged(skill_c)
	else:
		ranged_value.visible = false
		ranged_type_icon.visible = false


## 更新防御塔信息
func _update_tower_info() -> void:
	var tower_c: TowerComponent = selected_entity.get_node_or_null(Constants.CN_TOWER)

	if tower_c.get_child_count() == 0:
		var skill_c: SkillComponent = selected_entity.get_node_or_null(Constants.CN_SKILL)
		if skill_c:
			_set_value_ranged(skill_c)
		else:
			ranged_type_icon.visible = false
			ranged_value.visible = false
	else:
		var first_entity: Entity = tower_c.get_child(0)
		var skill_c: SkillComponent = first_entity.get_node_or_null(Constants.CN_SKILL)
		if skill_c:
			_set_value_ranged(skill_c)


func _set_value_ranged(skill_c: SkillComponent) -> void:
	var first_ranged_skill: RangedSkill = skill_c.get_child(0)
	var damage_influence := first_ranged_skill.config.influence as DamageInfluence
	if damage_influence:
		ranged_value.text = "%d-%d/%.1f" % [damage_influence.min_value, damage_influence.max_value, first_ranged_skill.config.cooldown]
	
	
func _set_value_melee(melee_c: MeleeComponent) -> void:
	var first_melee_skill: MeleeSkill = melee_c.get_child(0)
	var damage_influence := first_melee_skill.config.influence as DamageInfluence
	if damage_influence:
		melee_value.text = "%d-%d/%.1f" % [damage_influence.min_value, damage_influence.max_value, first_melee_skill.config.cooldown]
