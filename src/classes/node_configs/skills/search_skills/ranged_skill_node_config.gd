@tool
extends SearchSkillNodeConfig
class_name RangedSkillNodeConfig
## 单次远程技能节点配置资源。
##
## [RangedSkillNodeConfig] 用于存储 [RangedSkill] 的可配置数据。


## 拦截目标时是否可以释放远程技能。
@export var with_melee: bool = false

@export_group("Bullet")
## 子弹场景路径。
@export_file("*.tscn") var bullet_scene: String = ""
## 子弹发射数量。
@export var bullet_count: int = 1
## 子弹初始位置偏移组。
@export var bullet_offsets: FacingOffsetSet = null:
	set(v):
		Utils.rebind_changed(bullet_offsets, v, emit_changed)
		bullet_offsets = v
		emit_changed()
## 子弹发射的角度范围。
@export_range(0, 360, 0.1, "radians_as_degrees") var bullet_angle_range: float = 0.0
## 子弹发射模式。
@export var bullet_spawn_mode: RangedSkill.BulletSpawnMode = RangedSkill.BulletSpawnMode.EQUAL_INTERVAL

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"searcher": emit_changed,
	"bullet_offsets": emit_changed,
}


func _init() -> void:
	super()
		
	Utils.connect_property_signals(self, _init_connect_property_signals)
