extends SelectMenuButton
class_name SelectMenuButtonUpgrade


## 升级为的实体场景。
@export var upgrade_to: PackedScene = null

@export_group("Ref")
## 价格标签引用。
@export var price_tag: TextureRect = null

@onready var price_tag_label: Label = price_tag.get_node("Label")

var preview: PackedScene = null
var preview_entity: Entity = null


func _update() -> void:
	var upgrade_target: Entity = EntityMgr.get_entity_data(
		upgrade_to
	)
	var tower_c: TowerComponent = upgrade_target.get_node_or_null(C.CN_TOWER)
	
	var price: float = 0.0
	if tower_c.tower_type == TowerComponent.TowerType.TOWER_BUILD:
		var build_target: Entity = EntityMgr.get_entity_data(upgrade_target.build_target)
		var build_target_tower_c: TowerComponent = build_target.get_node_or_null(C.CN_TOWER)
		price = build_target_tower_c.price
	else:
		price = tower_c.price

	if price > GameMgr.cash:
		_disable()
	else:
		_enable()
			
	price_tag_label.text = "%d" % price

	
## 点击并松开按钮时调用的信号处理函数
func _on_pressed() -> void:
	if not U.is_valid_entity(selected_entity):
		return

	var tower_c: TowerComponent = selected_entity.get_node_or_null(C.CN_TOWER)
	tower_c.upgrade_to = upgrade_to
	
	_hide_preview()


func _on_mouse_entered() -> void:
	super()

	if not U.is_valid_entity(selected_entity):
		return
	
	if preview:
		preview_entity = EntityMgr.create_entity(preview)
		preview_entity.global_position = selected_entity.global_position
		
		preview_entity.insert_entity()
	
	
func _on_mouse_exited() -> void:
	super()
	
	if not U.is_valid_entity(selected_entity):
		return
	
	_hide_preview()
		
		
func _hide_preview() -> void:
	if preview_entity:
		preview_entity.remove_entity()
		preview_entity = null
