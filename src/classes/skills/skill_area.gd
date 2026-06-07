@tool
extends Skill
class_name SkillArea
## 范围技能节点。
##
## SkillArea 会搜索到第一个目标实体，然后对它造成影响。[br]
## 与 [SkillRanged] 不同，SkillArea 不会创建子弹作为中介，而是直接对目标实体造成影响。[br]
## 相当于对 [InfluenceResource] 封装了一个搜索目标的机制，以搜索到的第一个目标为中心造成影响。


## 搜索资源。
@export var search: SearchResource = null:
	set(v): 
		search = v
		if Engine.is_editor_hint():
			U.connect_resource_changed(search, queue_redraw)
			queue_redraw()
## 影响资源。
@export var influence: InfluenceResource = null:
	set(v): 
		influence = v
		if Engine.is_editor_hint():
			U.connect_resource_changed(influence, queue_redraw)
			queue_redraw()
## 是否搜索第一个目标位置，如果为 false 则以释放者的位置为中心造成影响，而非第一个目标的位置。
@export var search_target_pos: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(search, queue_redraw)
		U.connect_resource_changed(influence, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if search:
			search.draw(self, position)
		if influence:
			influence.draw(self, position)
		
		
func _do_skill(e: Entity, skill_idx: int, target: Entity = null) -> void:
	if not target:
		var targets: Array[Entity] = search.search_targets(e, e.global_position)
		if not targets:
			return

		target = targets[0]
	e.look_point = target.global_position
	start_cooldown(e, skill_idx)

	e.play_animation(animation)
	AudioMgr.play_sfx(sfx)
	if await e.y_wait(delay) or not target:
		compensate_cooldown(e, skill_idx)
		return

	if search_target_pos:
		influence.take_influence(e, target, target.global_position)
	else:
		influence.take_influence(e, target, e.global_position)

	if await e.y_wait_animation(animation):
		return
		
	e.play_animation(e.idle_animation, &"idle")
