@tool
extends NodeConfig
class_name TowerComponentNodeConfig
## 防御塔组件节点配置资源。


## 防御塔类型。
@export var tower_type: TowerComponent.TowerType = TowerComponent.TowerType.TOWER_HOLDER
## 塔位场景路径。
@export_file("*.tscn") var tower_holder: String = ""
## 默认集结点局部位置。
@export var default_rally_center_position := Vector2.ZERO:
	set(v):
		default_rally_center_position = v
		emit_changed()

@export_group("Sell")
## 价格。
@export var price: float = 0.0
## 出售比例（%）
@export var sell_ratio: float = 0.5
## 出售音效组。
@export var sell_sfx: AudioGroup = null

@export_group("Shooter Switch")
## 是否启用射手轮换释放技能。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var shooter_alternation_enabled: bool = false
## 轮换的射手实体索引列表。
@export var shooter_alternation_indexs: Array[int] = []
## 轮换释放技能偏移时间（秒）。
@export var shooter_alternation_offset: float = 0.1
