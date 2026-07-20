@tool
extends Skill
class_name RangedSkill
## 单次远程技能节点。
##
## RangedSkill 会生成一个子弹，以子弹作为中介，对目标造成影响。子弹会以特定轨迹飞行，到达目标后造成影响。


## 子弹生成模式枚举。
enum BulletSpawnMode {
	## 子弹生成模式：随机，子弹会以 [member bullet_angle_range] 范围内的随机角度生成。
	RANDOM,
	## 子弹生成模式：等距，子弹会以 [member bullet_angle_range] 范围内等距的角度生成。
	EQUAL_INTERVAL,
}


## 拦截目标时是否可以释放远程技能。
@export var with_melee: bool = false
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v): 
		searcher = v
		U.resource_redraw_setter(self, searcher)

@export_group("Bullet")
## 子弹场景路径。
@export_file("*.tscn") var bullet: String = ""
## 子弹发射数量。
@export var bullet_count: int = 1
## 子弹初始位置偏移组。
@export var bullet_offsets: OffsetGroup = null:
	set(v): 
		bullet_offsets = v
		U.resource_redraw_setter(self, bullet_offsets)
## 子弹发射的角度范围。
@export_range(0, 360, 0.1, "radians_as_degrees") var bullet_angle_range: float = 0.0
## 子弹发射模式。
@export var bullet_spawn_mode: BulletSpawnMode = BulletSpawnMode.EQUAL_INTERVAL
## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v): 
		influence = v
		U.resource_redraw_setter(self, influence)


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(bullet_offsets, queue_redraw)
		U.connect_resource_changed(influence, queue_redraw)
		U.connect_resource_changed(searcher, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if influence:
			influence.draw(self, position)

		searcher.draw(self, position)
		OffsetGroup.draw_offset_group(self, bullet_offsets)


func _do_skill(e: Entity, target: Entity = null) -> void:
	if not target:
		target = searcher.search_target(e.global_position, e)
		if not target:
			return
		
	e.look_point = target.global_position
	start_cooldown(e)

	e.play_animation(animation, &"ranged")
	AudioMgr.play_sfx(sfx)
	if await e.y_wait(delay):
		compensate_cooldown(e)
		return

	if not target:
		target = searcher.search_target(e.global_position, e)
		if not target:
			compensate_cooldown(e)
			return

	spawn_bullets(e, target)

	await e.y_wait_animation(animation)


## 生成子弹。
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

		var b_rotation: float = 0.0

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
