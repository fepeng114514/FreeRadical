extends ECSSystem
class_name SpriteSystem
## 精灵系统。
##
## SpriteSystem 负责处理拥有 [SpriteComponent] 精灵组件的实体的精灵。


func _on_insert(entity: ECSEntity) -> bool:
	entity = entity as Entity
 	
	var sprite_c: SpriteComponent = entity.get_node_or_null(Constants.CN_SPRITE)
	if not sprite_c:
		return true
		
	entity.play_animation(entity.idle_animation, &"idle", true)
		
	return true
