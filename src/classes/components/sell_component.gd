@tool
extends Component
class_name SellComponent
## 出售组件。
##
## SellComponent 可以使实体被出售。


## 出售生成的实体类型枚举。
enum CreatedEntityType {
	## 出售生成的实体类型：塔位。
	TOWER_HOLDER
}


@export var config: SellComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 出售状态。
var is_selling: bool = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	for warning in PriceRecord.get_not_found_configuration_warnings(parent):
		warnings.append(warning)

	return warnings
