extends Resource
class_name UpgradeItem


## 是否禁用。
@export var disabled: bool = false
## 升级目标场景路径。
@export_file("*.tscn") var upgrade_to: String = ""
## 升级价格。
@export var price: float = 0.0
## 升级项选择菜单按钮数据。
@export var select_menu_upgrade_item_button_data: SelectMenuButtonData = null
