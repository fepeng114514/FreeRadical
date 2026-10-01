extends Control
class_name TowerUpgradeSelectMenu
## 防御塔升级选择菜单
##
## 负责显示和隐藏选择菜单，并根据实体类型显示对应的按钮


@export var select_menu_config: SelectMenuConfig = null

@export_group("Ref")
@export var range_info_controller: RangeInfoController = null
@export var animation_player: AnimationPlayer = null
@export var place_holders: Control = null
@export var ring: TextureRect = null

@export_subgroup("Scene")
@export var rally_button_scene: PackedScene = null
@export var sell_button_scene: PackedScene = null
@export var upgrade_button_scene: PackedScene = null
@export var upgrade_skill_button_scene: PackedScene = null

## 当前选择的实体
var selected_entity: Entity = null


func _ready() -> void:
	visible = false
	
	SelectManager.entity_selected.connect(_show)
	SelectManager.entity_deselected.connect(_hide)
	
	
func _process(_delta: float) -> void:
	if not visible:
		return
		
	if not selected_entity:
		_hide()
		return
		
	var select_c: SelectComponent = selected_entity.get_node_or_null(Constants.CN_SELECT)
	if not select_c:
		return
		
	global_position = selected_entity.global_position + select_c.config.select_menu_offset

	
func _show(entity: Entity) -> void:
	_clear()
	
	var select_c: SelectComponent = entity.get_node_or_null(Constants.CN_SELECT)
	if not select_c:
		return

	if select_c.config.select_menu_type != SelectComponent.SelectMenuType.TOWER:
		return

	var group: SelectMenuButtonGroup = select_menu_config.group_dict.get(entity.scene_name)
	if not group:
		Log.error("未找到选择菜单组: %s" % entity.scene_name)
		return

	for data: SelectMenuButtonData in group.button_list:		
		var button: SelectMenuButton = null
		if data is SelectMenuButtonDataUpgrade:
			button = upgrade_button_scene.instantiate()
			button.upgrade_to = data.upgrade_to
			button.preview = data.preview
			
			if data.icon:
				button.button.icon = data.icon
		elif data is SelectMenuButtonDataUpgradeSkill:
			button = upgrade_skill_button_scene.instantiate()
			button.upgrade_skill_index = data.upgrade_skill_index
			
			if data.icon:
				button.button.icon = data.icon
		elif data is SelectMenuButtonDataRally:
			button = rally_button_scene.instantiate()
		elif data is SelectMenuButtonDataSell:
			button = sell_button_scene.instantiate()
		
		button.select_menu = self
		button.position = place_holders.list[data.place]
		button.selected_entity = entity
		ring.add_child(button)
		
	selected_entity = entity
	visible = true
	global_position = entity.global_position + select_c.config.select_menu_offset
		
	animation_player.play("show")
	
	
func _hide() -> void:
	animation_player.play("hide")
	
	await animation_player.animation_finished
	_clear()
	
	
## 清空菜单
func _clear() -> void:
	visible = false
	
	for child: Control in ring.get_children():
		if child is SelectMenuButton:
			child.queue_free()
		
	selected_entity = null
