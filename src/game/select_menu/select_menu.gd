extends Control
class_name TowerUpgradeSelectMenu
## 防御塔升级选择菜单
##
## 负责显示和隐藏选择菜单，并根据实体类型显示对应的按钮


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
		
	var select_c: SelectComponent = selected_entity.get_node_or_null(Constants.SELECT_COMPONENT_NODE_PATH)
	global_position = selected_entity.global_position + select_c.config.select_menu_offset

	
func _show(entity: Entity) -> void:
	_clear()
	
	var select_c: SelectComponent = entity.get_node_or_null(Constants.SELECT_COMPONENT_NODE_PATH)
	if not select_c:
		return
		
	if not select_c.config.select_menu_enabled:
		return

	selected_entity = entity
	_create_buttons()
	
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


func _create_buttons() -> void:
	_try_create_sell_button()
	_try_create_upgrade_button()
	_try_create_rally_button()


func _try_create_sell_button() -> void:
	var sell_c: SellComponent = selected_entity.get_node_or_null(Constants.SELL_COMPONENT_NODE_PATH)
	if not sell_c:
		return

	var config: SellComponentNodeConfig = sell_c.config
	if config.disabled:
		return

	if not config.select_menu_sell_button_data:
		return

	_create_button(config.select_menu_sell_button_data, sell_button_scene)


func _try_create_upgrade_button() -> void:
	var upgrade_c: UpgradeComponent = selected_entity.get_node_or_null(Constants.UPGRADE_COMPONENT_NODE_PATH)
	if not upgrade_c:
		return

	var items: Array[UpgradeItem] = upgrade_c.config.upgrade_items.upgrade_items
	for i: int in items.size():
		var upgrade_item: UpgradeItem = items[i]
		if upgrade_item.disabled:
			continue

		if not upgrade_item.select_menu_upgrade_item_button_data:
			continue

		var button: SelectMenuUpgradeButton = _create_button(upgrade_item.select_menu_upgrade_item_button_data, upgrade_button_scene)
		button.upgrade_item_index = i


func _try_create_rally_button() -> void:
	var barrack_c: BarrackComponent = selected_entity.get_node_or_null(Constants.BARRACK_COMPONENT_NODE_PATH)
	if not barrack_c:
		return

	var config: BarrackComponentNodeConfig = barrack_c.config
	if config.disabled:
		return

	if not config.select_menu_rally_button_data:
		return

	_create_button(config.select_menu_rally_button_data, rally_button_scene)


func _create_button(button_data: SelectMenuButtonData, button_scene: PackedScene) -> SelectMenuButton:
	var button: SelectMenuButton = button_scene.instantiate()
	button.select_menu = self
	button.selected_entity = selected_entity
	button.position = place_holders.list[button_data.place]
	button.button.icon = button_data.icon
	button.preview_entity_scene = button_data.preview_entity_scene
	ring.add_child(button)
	return button
