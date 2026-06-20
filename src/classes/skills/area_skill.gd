@tool
extends Skill
class_name AreaSkill
## 范围技能节点。
##
## AreaSkill 会搜索到第一个目标实体，然后对它造成影响。[br]
## 与 [RangedSkill] 不同，AreaSkill 不会创建子弹作为中介，而是直接对目标实体造成影响。[br]
## 相当于对 [Influence] 封装了一个搜索目标的机制，以搜索到的第一个目标为中心造成影响。


## 搜索资源。
@export var search: SearchResource = null:
	set(v): 
		search = v
		U.resource_redraw_setter(self, search)
## 影响资源。
@export var influence: Influence = null:
	set(v): 
		influence = v
		U.resource_redraw_setter(self, influence)


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
	if search:
		target = search.search_target(e, e.global_position)
		if not target:
			return
	
	if target:
		e.look_point = target.global_position
	start_cooldown(e, skill_idx)

	e.play_animation(animation)
	AudioMgr.play_sfx(sfx)
	if await e.y_wait(delay) or search and not target:
		compensate_cooldown(e, skill_idx)
		return

	if search:
		influence.take_influence(e, target, target.global_position)
	else:
		influence.take_influence(e, target, e.global_position)

	if await e.y_wait_animation(animation):
		return
		
	e.play_animation(e.idle_animation, &"idle")
