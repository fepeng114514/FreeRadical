extends Control
class_name SelectMenuController
## 选择菜单控制器
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
var scale_tween: Tween = null
var is_scale_tweening: bool = false


func _ready() -> void:
	scale = Vector2.ZERO
	visible = false
	
	SelectMgr.entity_selected.connect(_show)
	SelectMgr.entity_deselected.connect(_hide)
	
	
func _process(_delta: float) -> void:
	if not visible:
		return
		
	if not U.is_valid_entity(selected_entity):
		_hide()
		return
		
	var ui_c: UIComponent = selected_entity.get_node_or_null(C.CN_UI)
	if not ui_c:
		return
		
	global_position = selected_entity.global_position + ui_c.select_menu_offset

	
func _show(e: Entity) -> void:
	_clear()
	
	var ui_c: UIComponent = e.get_node_or_null(C.CN_UI)
	if not ui_c:
		return
		
	var group: SelectMenuButtonGroup = null
		
	var tower_c: TowerComponent = e.get_node_or_null(C.CN_TOWER)
	if tower_c and tower_c.tower_type == TowerComponent.TowerType.TOWER_HOLDER:
		group = select_menu_config.group_dict["tower_holder"]
	else:
		group = select_menu_config.group_dict.get(e.scene_name)
	
	if not group:
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
			button.upgrade_skill_idx = data.upgrade_skill_idx
			
			if data.icon:
				button.button.icon = data.icon
		elif data is SelectMenuButtonDataRally:
			button = rally_button_scene.instantiate()
		elif data is SelectMenuButtonDataSell:
			button = sell_button_scene.instantiate()
		
		button.select_menu = self
		button.position = place_holders.list[data.place]
		button.selected_entity = e
		ring.add_child(button)
		
	selected_entity = e
	visible = true
	global_position = e.global_position + ui_c.select_menu_offset
		
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
