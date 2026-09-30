@tool
extends Component
class_name BuildComponent
## 建造组件。
##
## BuildComponent 可以让实体建造另一个实体。


const build_progress_bar_path: NodePath = ^"BuildTextureProgressBar"


@export var config: BuildComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 建造时间，单位为秒。
@export var build_time: float = 1.0
## 建造目标实体。
@export_file("*.tscn") var build_target: String = ""

@onready var build_progress_bar: TextureProgressBar = get_node_or_null(build_progress_bar_path)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()
	if not build_progress_bar:
		warnings.append("请增加一个 BuildTextureProgressBar 建造进度条子节点，否则无法显示建造进度。")

	return warnings


func _on_child_order_changed() -> void:
	super()
	
	build_progress_bar = get_node_or_null(build_progress_bar_path)
