extends SelectMenuButton
class_name SelectMenuButtonUpgradeSkill


## 升级的技能索引
@export var upgrade_skill_index: int = Constants.UNSET

@export_group("Ref")
@export var price_tag: TextureRect = null

@onready var price_tag_label: Label = price_tag.get_node("Label")


#func _on_pressed() -> void:
	# if not selected_entity:
	# 	return

	#var tower_c: TowerComponent = selected_entity.get_node_or_null(Constants.CN_TOWER)
