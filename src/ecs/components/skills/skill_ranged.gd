@tool
extends Skill
class_name SkillRanged
## 单次远程技能节点



## 子弹生成模式枚举
enum BulletSpawnMode {
	## 子弹生成模式：随机
	##
	## 子弹会以 bullet_angle_range 范围内的随机角度生成
	RANDOM,
	## 子弹生成模式：等距
	##
	## 子弹会以 bullet_angle_range 范围内等距的角度生成
	EQUAL_INTERVAL,
}


## 拦截目标时是否可以释放远程技能
@export var with_melee: bool = false

@export_group("Bullet")
## 子弹场景名称
@export var bullet: String = ""
## 子弹发射数量
@export var bullet_count: int = 1
## 子弹初始位置偏移
@export var bullet_offsets: OffsetGroup = null:
	set(value):
		bullet_offsets = value
		if Engine.is_editor_hint():
			U.connect_offset_group_changed(bullet_offsets, _on_bullet_offsets_changed)
		queue_redraw()
## 子弹发射的角度范围，单位为度
@export_range(0, 360, 0.1, "radians_as_degrees") var bullet_angle_range: float = 0
## 子弹发射模式
@export var bullet_spawn_mode: BulletSpawnMode = BulletSpawnMode.EQUAL_INTERVAL

@export_group("Search")
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 最小搜索距离
@export var min_range: float = 0:
	set(value):
		min_range = value
		queue_redraw()
## 最大搜索距离
@export var max_range: float = 300:
	set(value):
		max_range = value
		queue_redraw()
## 技能标识
@export var flags: C.Flag = C.Flag.NONE
## 不可搜索的目标的标识
@export var bans: int = 0
## 可搜索的目标的场景名称列表
@export var whitelist := PackedStringArray()
## 不可搜索的目标的场景名称列表
@export var blacklist := PackedStringArray()

@export_group("Damage")
## 子弹最小伤害
@export var damage_min: float = 0
## 子弹最大伤害
@export var damage_max: float = 0
## 伤害类型
@export var damage_type: int = C.DamageType.PHYSICAL
## 伤害标识
@export var damage_flags: int = 0
## 子弹携带的状态效果
@export var mods := PackedStringArray()

@export_subgroup("Area Damage")
## 是否启用范围伤害
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var damage_area_enable: bool = false
## 最小伤害半径
@export var damage_min_radius: float = 0
## 最大伤害半径
@export var damage_max_radius: float = 0
## 最大影响数量
@export var max_influenced: int = C.UNSET
## 范围伤害的圆心偏移
@export var damage_offsets: OffsetGroup = null:
	set(value):
		damage_offsets = value
		if Engine.is_editor_hint():
			U.connect_offset_group_changed(damage_offsets, _on_damage_offsets_changed)
		queue_redraw()
## 是否可以伤害重复敌人
@export var can_damage_same: bool = false
## 范围伤害的搜索模式
@export var damage_search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 范围伤害是否随距离衰减
@export var damage_falloff_enabled: bool = false

@export_subgroup("Heal")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var heal_enable: bool = false
@export var heal_value: float = 0
@export var heal_type: HealthComponent.HealType = HealthComponent.HealType.ADD


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_offset_group_changed(damage_offsets, _on_damage_offsets_changed)
		U.connect_offset_group_changed(bullet_offsets, _on_bullet_offsets_changed)


func _on_damage_offsets_changed() -> void:
	queue_redraw()


func _on_bullet_offsets_changed() -> void:
	queue_redraw()


func _draw() -> void:
	if Engine.is_editor_hint():
		U.draw_offset_group(self, damage_offsets)
		U.draw_offset_group(self, bullet_offsets)
		U.draw_range_circle(self, position, min_range, max_range)



func _do_skill(e: Entity) -> void:
	var target: Entity = search_target(e, self)
	if not target:
		return

	e.look_point = target.global_position

	e.play_animation_by_look(animation, "ranged")
	AudioMgr.play_sfx(sfx)
	await e.y_wait(delay)

	if not target:
		return

	spawn_bullets(e, target)

	await e.wait_animation(animation)


func spawn_bullets(
		e: Entity, 
		target: Entity
	) -> void:
	var e_to_target_angle: float = e.global_position.angle_to_point(target.global_position)
	var half_angle_range: float = bullet_angle_range / 2
	var da: float = (bullet_angle_range) / bullet_count + 1
	
	for i: int in bullet_count:
		var b = EntityMgr.create_entity(bullet)
		b.target_id = target.id
		b.source_id = e.id

		var b_rotation: float = 0

		match bullet_spawn_mode:
			BulletSpawnMode.EQUAL_INTERVAL:
				b_rotation = e_to_target_angle + (da * i + -half_angle_range)
			BulletSpawnMode.RANDOM:
				var random_angle: float = randf_range(
					-half_angle_range, half_angle_range	
				)
				b_rotation = e_to_target_angle + random_angle
				
		b.rotation = b_rotation
		var b_global_pos: Vector2 = e.global_position
		if bullet_offsets:
			var offset: Vector2 = bullet_offsets.get_offset_for_point(
				e.global_position, e.look_point
			)
			b_global_pos += offset
		b.global_position = b_global_pos

		var b_bullet_c: BulletComponent = b.get_node_or_null(C.CN_BULLET)
		b_bullet_c.damage_min = damage_min
		b_bullet_c.damage_max = damage_max
		b_bullet_c.damage_type = damage_type
		b_bullet_c.damage_flags = damage_flags
		b_bullet_c.mods = mods
		b_bullet_c.damage_area_enable = damage_area_enable
		b_bullet_c.damage_min_radius = damage_min_radius
		b_bullet_c.damage_max_radius = damage_max_radius
		b_bullet_c.max_influenced = max_influenced
		b_bullet_c.damage_offsets = damage_offsets
		b_bullet_c.can_damage_same = can_damage_same
		b_bullet_c.damage_search_mode = damage_search_mode
		b_bullet_c.damage_falloff_enabled = damage_falloff_enabled

		b_bullet_c.heal_enable = heal_enable
		b_bullet_c.heal_type = heal_type
		b_bullet_c.heal_value = heal_value

		b.insert_entity()
