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
@export var search: SearchResource = null:
	set(value):
		search = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(search, queue_redraw)
			queue_redraw()

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
			U.connect_resource_changed(bullet_offsets, queue_redraw)
			queue_redraw()
## 子弹发射的角度范围，单位为度
@export_range(0, 360, 0.1, "radians_as_degrees") var bullet_angle_range: float = 0
## 子弹发射模式
@export var bullet_spawn_mode: BulletSpawnMode = BulletSpawnMode.EQUAL_INTERVAL
## 伤害/治疗/范围伤害 统一资源
@export var influence: InfluenceResource = null:
	set(value):
		influence = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(influence, queue_redraw)
			queue_redraw()


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(bullet_offsets, queue_redraw)
		U.connect_resource_changed(influence, queue_redraw)
		U.connect_resource_changed(search, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if influence:
			influence.draw(self, position)

		if search:
			search.draw(self, position)
		U.draw_offset_group(self, bullet_offsets)


func _do_skill(e: Entity) -> void:
	var targets: Array[Entity] = search.search_targets(e, e.global_position)
	if not targets:
		return

	var target: Entity = targets[0]
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
		b_bullet_c.influence = influence.duplicate_deep()

		b.insert_entity()
