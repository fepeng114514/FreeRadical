@icon("res://assets/dpi_textures/at-icons/node2d/arrow_up.svg")
extends Component
class_name UpgradeComponent
## 升级组件。
##
## UpgradeComponent 可以使实体被升级。


## 升级目标场景路径。
@export_file("*.tscn") var upgrade_to: String = ""
## 升级价格。
@export var price: float = 0.0

var is_upgraded: bool = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	for warning in PriceRecord.get_not_found_configuration_warnings(parent):
		warnings.append(warning)

	return warnings
