@tool
@icon("res://assets/dpi_textures/at-icons/node2d/heart.svg")
extends Component
class_name HealthComponent
## 血量组件。
##
## HealthComponent 可以使实体拥有血量，血量为 0 时移除实体。


@export var config: HealthComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()

## 最大血量。
@export var hp_max: float = 100.0

@export_group("Buff")
## 物理护甲。
@export var physical_armor: float = 0.0
## 魔法护甲。
@export var magical_armor: float = 0.0
## 毒抗性。
@export var poison_armor: float = 0.0
## 回血。
@export var regen_hp: float = 0.0
## 回血冷却（秒）。
@export var regen_cooldown: float = Constants.UNSET
## 待机回血。
@export var idle_regen_hp: float = 0.0
## 待机回血冷却（秒）。
@export var idle_regen_cooldown: float = Constants.UNSET
## 伤害抗性，可以百分比减少受到的伤害。
@export var damage_resistance: float = 0.0
## 伤害减免，可以直接减少受到的伤害值。
@export var damage_reduction: float = 0.0
## 反伤，对伤害来源的反伤。
@export var spiked: float = Constants.UNSET
## 免疫的伤害类型。
@export var immuned: int = Damage.Type.NONE

@export_group("Debuff")
## 易伤，可以百分比增加受到的伤害值。
@export var vulnerable: float = 0.0

@export_group("Death")
## 死亡赏金。
@export var death_gold: float = 0.0
## 死亡动画组。
@export var death_animation: AnimationGroup = null
## 死亡音效组。
@export var death_sfx: AudioGroup = null
## 死亡后实体移除延迟（秒）。
@export var death_remove_delay: float = 2.0

## 当前血量。
var hp: float = 0.0:
	set(v): 
		hp = clampf(v, 0, hp_max)
		hp_percent = hp / hp_max * 100
		health_bar.value = hp_percent
var hp_percent: float = 0.0
## 回血时间戳。
var regen_ts: float = 0.0
## 待机回血时间戳。
var idle_regen_ts: float = 0.0

## 血条节点引用。
@onready var health_bar: TextureProgressBar = get_node_or_null("HealthBar")


func _ready() -> void:
	super()

	child_order_changed.connect(_on_child_order_changed)


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
	health_bar = get_node_or_null("HealthBar") 
	update_configuration_warnings()
