@tool
extends NodeConfig
class_name TowerComponentNodeConfig
## 防御塔组件节点配置资源。


## 防御塔类型。
@export var tower_type: TowerComponent.TowerType = TowerComponent.TowerType.NONE

@export_group("Shooter Alternation")
## 是否启用射手轮换释放技能。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var shooter_alternation_enabled: bool = false
## 轮换的射手实体列表。
@export var shooter_alternation_entities: Array[NodePath] = []
## 轮换释放技能偏移时间（秒）。
@export var shooter_alternation_offset: float = 0.1
