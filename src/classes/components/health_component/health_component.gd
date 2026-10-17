@tool
@icon("res://assets/dpi_textures/at-icons/node2d/heart.svg")
extends Component
class_name HealthComponent
## 血量组件。
##
## [HealthComponent] 可以让实体拥有血量，血量为 0 时移除实体。


const health_bar_path: NodePath = ^"HealthBar"


@export var config: HealthComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 当前血量。
var hp: float = 0.0:
	set(v): 
		last_hp = hp
		hp = clampf(v, 0, config.hp_max)
		hp_percent = hp / config.hp_max * 100
		health_bar.value = hp_percent
		queue_redraw()
var hp_percent: float = 0.0
## 上一次的血量。
var last_hp: float = 0.0
## 回血时间戳。
var regen_timestamp: float = 0.0
## 待机回血时间戳。
var idle_regen_timestamp: float = 0.0

## 血条节点引用。
@onready var health_bar: TextureProgressBar = get_node_or_null(health_bar_path)


func _ready() -> void:
	super()
	
	child_order_changed.connect(_on_child_order_changed)


func _draw() -> void:
	if not config:
		return
		
	if DebugManager.draw_health_enabled:
		draw_string(
			ThemeDB.fallback_font,
			health_bar.position,
			"%d/%d" % [hp, config.hp_max],
			HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			24,
			Color.GREEN
		)
		


func _validate_property(property: Dictionary):
	match property.name:
		"immuned":
			property.hint_string = "mask_check(%s)" % Damage.Type
			

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()
		
	if not health_bar:
		warnings.append("请增加一个 HealthBar 子节点，否则实体无法显示血条。")
		
	return warnings


func _on_child_order_changed() -> void:
	health_bar = get_node_or_null(health_bar_path)
