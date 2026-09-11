@tool
extends SearchSkill
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
		Utils.resource_redraw_setter(self, searcher)

@export_group("Bullet")
## 子弹场景路径。
@export_file("*.tscn") var bullet_scene: String = ""
## 子弹发射数量。
@export var bullet_count: int = 1
## 子弹初始位置偏移组。
@export var bullet_offsets: OffsetGroup = null:
	set(v): 
		bullet_offsets = v
		Utils.resource_redraw_setter(self, bullet_offsets)
## 子弹发射的角度范围。
@export_range(0, 360, 0.1, "radians_as_degrees") var bullet_angle_range: float = 0.0
## 子弹发射模式。
@export var bullet_spawn_mode: BulletSpawnMode = BulletSpawnMode.EQUAL_INTERVAL


func _ready() -> void:
	if Engine.is_editor_hint():
		Utils.connect_resource_changed(bullet_offsets, queue_redraw)
		Utils.connect_resource_changed(searcher, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		searcher.draw(self, position)
		OffsetGroup.draw_offset_group(self, bullet_offsets)


func _use_skill(entity: Entity, target: Entity = null) -> void:
	target = searcher.search_target(get_search_global_position(entity), entity)
	if not target:
		return
		
	entity.facing_global_position = target.global_position
	start_cooldown()

	entity.play_animation(animation, &"ranged")
	AudioManager.play_sfx(sfx)
	if await entity.y_wait(delay):
		compensate_cooldown()
		return

	if not target:
		target = searcher.search_target(get_search_global_position(entity), entity)
		if not target:
			compensate_cooldown()
			return

	_spawn_bullets(entity, target)

	await entity.y_wait_animation(animation)


## 生成子弹。
func _spawn_bullets(
		entity: Entity, 
		target: Entity
	) -> void:
	var entity_to_target_angle: float = entity.global_position.angle_to_point(target.global_position)
	var half_angle_range: float = bullet_angle_range / 2
	var da: float = (bullet_angle_range) / bullet_count + 1
	
	for bullet_index: int in bullet_count:
		var bullet = ECSEntityManager.create_entity(bullet_scene)
		bullet.target_id = target.id
		bullet.source_id = entity.id

		var bullet_rotation: float = 0.0
		match bullet_spawn_mode:
			BulletSpawnMode.EQUAL_INTERVAL:
				bullet_rotation = entity_to_target_angle + (da * bullet_index + -half_angle_range)
			BulletSpawnMode.RANDOM:
				var random_angle: float = randf_range(
					-half_angle_range, half_angle_range	
				)
				bullet_rotation = entity_to_target_angle + random_angle
				
		bullet.rotation = bullet_rotation
		var bullet_global_position: Vector2 = entity.global_position
		if bullet_offsets:
			var offset: Vector2 = bullet_offsets.get_offset_toward_point(
				entity.global_position, entity.facing_global_position
			)
			bullet_global_position += offset
		bullet.global_position = bullet_global_position

		ECSEntityManager.queue_insert_entity(bullet)
