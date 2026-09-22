@abstract
extends Skill
class_name SearchSkill
## 搜索技能基类。


## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null


func _draw() -> void:
	if DebugManager.draw_range_enabled:
		if searcher:
			searcher.draw_search_range(self, position)


## 获取搜索中心。
func get_search_global_position(entity: Entity) -> Vector2:
	var search_global_position: Vector2 = entity.global_position
	if entity.source_type == Entity.SourceType.TOWER_SHOOTER:
		search_global_position.y -= entity.position.y

	return search_global_position