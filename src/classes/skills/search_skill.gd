@abstract
extends Skill
class_name SearchSkill
## 搜索技能基类。


## 获取搜索中心。
func get_search_center(e: Entity) -> Vector2:
	var search_center: Vector2 = e.global_position
	if e.source_type == Entity.SourceType.TOWER_SHOOTER:
		search_center.y -= e.position.y

	return search_center