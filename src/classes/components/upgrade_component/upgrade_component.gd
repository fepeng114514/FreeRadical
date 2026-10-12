@tool
@icon("res://assets/dpi_textures/at-icons/node2d/arrow_up.svg")
extends Component
class_name UpgradeComponent
## 升级组件。
##
## [UpgradeComponent] 可以让实体被升级。


const upgrade_progress_bar_path: NodePath = ^"UpgradeTextureProgressBar"

@export var config: UpgradeComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 当前升级项索引。
var current_upgrading_index: int = -1


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	for warning in PriceRecord.get_not_found_configuration_warnings(parent):
		warnings.append(warning)

	return warnings
