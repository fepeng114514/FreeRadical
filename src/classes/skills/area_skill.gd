@tool
extends SearchSkill
class_name AreaSkill
## 范围技能节点。
##
## AreaSkill 会搜索到第一个目标实体，然后对它造成影响。[br]
## 与 [RangedSkill] 不同，AreaSkill 不会创建子弹作为中介，而是直接对目标实体造成影响。[br]
## 相当于对 [Influence] 封装了一个搜索目标的机制，以搜索到的第一个目标为中心造成影响。


## 搜索资源，用于搜索目标，如果不设置该资源，将会以释放者的位置为中心造成影响。
@export var searcher: Searcher = null:
	set(v): 
		searcher = v
		U.resource_redraw_setter(self, searcher)
## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v): 
		influence = v
		U.resource_redraw_setter(self, influence)


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(searcher, queue_redraw)
		U.connect_resource_changed(influence, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if searcher:
			searcher.draw(self, position)
		if influence:
			influence.draw(self, position)
		
		
func _use_skill(e: Entity, target: Entity = null) -> void:
	if searcher:
		target = searcher.search_target(get_search_center(e), e)
		if not target:
			return
	
		e.look_point = target.global_position
	start_cooldown()

	e.play_animation(animation)
	AudioMgr.play_sfx(sfx)
	if await e.y_wait(delay) or searcher and not target:
		compensate_cooldown()
		return

	if searcher:
		if not target:
			target = searcher.search_target(get_search_center(e), e)
			if not target:
				compensate_cooldown()
				return
		
		influence.take_influence(e, target, target.global_position)
	else:
		influence.take_influence(e, e, e.global_position)

	if await e.y_wait_animation(animation):
		return
		
	e.play_animation(e.idle_animation, &"idle")