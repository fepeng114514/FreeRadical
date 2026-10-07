@tool
extends NodeConfig
class_name SellComponentNodeConfig
## 出售组件节点配置资源。


## 是否禁用。
@export var disabled: bool = false
## 出售比例（%）
@export var sell_ratio: float = 0.5
## 出售音效组。
@export var sell_sfx: AudioGroup = null
## 出售后创建的实体类型。
@export var created_entity_type: SellComponent.CreatedEntityType = SellComponent.CreatedEntityType.TOWER_HOLDER
## 出售按钮数据。
@export var select_menu_sell_button_data: SelectMenuButtonData = null
