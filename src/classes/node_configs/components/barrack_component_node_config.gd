@tool
extends NodeConfig
class_name BarrackComponentNodeConfig
## 兵营组件节点配置资源。


## 是否禁用。
@export var disabled: bool = false
## 选择菜单集结按钮数据。
@export var select_menu_rally_button_data: SelectMenuButtonData = null

@export_group("Rally")
## 最小集结范围。
@export var rally_min_range: float = 0.0:
	set(v):
		rally_min_range = v
		emit_changed()
## 最大集结范围。
@export var rally_max_range: float = 300:
	set(v):
		rally_max_range = v
		emit_changed()
## 集结点半径，影响士兵与集结点之间的距离。
@export var rally_radius: float = 30.0:
	set(v):
		rally_radius = v
		emit_changed()
## 集结音效组。
@export var rally_sfx: AudioGroup = null

@export_group("Spawn")
## 士兵场景路径。
@export_file("*.tscn") var soldier_scene: String = ""
## 生成士兵间隔（秒）。
@export var spawn_interval: float = 10.0
## 士兵生成偏移组。
@export var spawn_offsets: OffsetGroup = null:
	set(v):
		Utils.rebind_changed(spawn_offsets, v, emit_changed)
		spawn_offsets = v
		emit_changed()
## 最大士兵数量。
@export var max_soldier_count: int = 3:
	set(v):
		max_soldier_count = v
		emit_changed()
## 生成士兵播放的动画。
@export var animation: AnimationGroup = null
## 生成士兵延迟（秒），用于在动画播放到特定帧后生成士兵。
@export var delay: float = 0.0
## 生成士兵播放的音效。
@export var sfx: AudioGroup = null

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"spawn_offsets": emit_changed,
}


func _init() -> void:
	super()
		
	Utils.connect_property_signals(self, _init_connect_property_signals)