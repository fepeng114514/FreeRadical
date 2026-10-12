extends Resource
class_name UpgradeItem
## 升级项资源。
## [UpgradeItem] 是升级组件的升级项资源。它包含了升级项的配置信息，包括升级目标场景路径、升级价格等，用于 [UpgradeComponent] 升级实体。



## 是否禁用。
@export var disabled: bool = false
## 升级目标场景路径。
@export_file("*.tscn") var upgrade_to: String = ""
## 升级价格。
@export var price: float = 0.0
## 升级项选择菜单按钮数据。
@export var select_menu_upgrade_item_button_data: SelectMenuButtonData = null
