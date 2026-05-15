@tool
extends SkillBase
class_name SkillArea
## 范围技能节点


## 最大可影响的实体数量
@export var max_influence: int = C.UNSET
@export var center_offsets: OffsetGroup = null:
	set(value):
		center_offsets = value
		if Engine.is_editor_hint():
			U.connect_offset_group_changed(center_offsets, _on_center_offsets_changed)
		queue_redraw()
## 状态效果场景名称
@export var mods := PackedStringArray()

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
@export var center_in_target_pos: bool = false
## 技能标识
@export var flags: C.Flag = C.Flag.NONE
## 不可搜索的目标的标识
@export var bans: int = 0
## 可搜索的目标的场景名称列表
@export var whitelist := PackedStringArray()
## 不可搜索的目标的场景名称列表
@export var blacklist := PackedStringArray()

@export_group("Damage")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var damage_enable: bool = false
## 最小伤害
@export var damage_min: float = 0
## 最大伤害
@export var damage_max: float = 0
## 伤害类型
@export var damage_type: int = C.DamageType.TRUE
## 伤害标识
@export var damage_flags: int = 0


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_offset_group_changed(center_offsets, _on_center_offsets_changed)


func _on_center_offsets_changed() -> void:
	queue_redraw()


func _draw() -> void:
	if Engine.is_editor_hint():
		U.draw_offset_group(self, center_offsets)
		U.draw_range_circle(self, position, min_range, max_range)
		
		
func _do_skill(e: Entity) -> void:
	var targets: Array[Entity] = []
	targets = search_targets(e, self)
	if not targets:
		return

	var target: Entity = targets[0]
	e.look_point = target.global_position

	e.play_animation_by_look(animation, "ranged")
	AudioMgr.play_sfx(sfx)
	await e.y_wait(delay)

	if not target:
		return

	var e_global_pos: Vector2 = e.global_position
	var center_pos: Vector2 = e_global_pos if not center_in_target_pos else target.global_position
	if center_pos:
		var center_offset: Vector2 = center_offsets.get_offset_for_point(e_global_pos, e.look_point)
		center_pos += center_offset

	var e_id: int = e.id
	for t: Entity in targets:
		var t_id: int = t.id
		
		if damage_enable:
			var d := Damage.new()
			d.target_id = t.id
			d.source_id = e_id
			d.source_name = e.name
			d.value = d.get_random_value(damage_min, damage_max)
			d.damage_type = damage_type
			d.damage_flags = damage_flags
			d.insert_damage()
			
		EntityMgr.create_mods(t_id, mods, e_id)

	await e.wait_animation(animation)
