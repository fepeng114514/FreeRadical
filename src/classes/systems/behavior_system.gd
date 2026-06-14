extends System
class_name BehaviorSystem
## 行为系统。
##
## BehaviorSystem 负责处理与管理行为树。


## 行为的更新方法缓存
var _update_caches: Array[Callable] = []
## 行为的插入方法缓存
var _insert_caches: Array[Callable] = []
## 行为的移除方法缓存
var _remove_caches: Array[Callable] = []
## 行为的跳过方法缓存
var _skip_caches: Array[Callable] = []

## 行为的数量。
@onready var _behavior_count: int = get_child_count()


func _ready() -> void:
	for child: Behavior in get_children():
		_update_caches.append(child._on_update)
		_insert_caches.append(child._on_insert)
		_remove_caches.append(child._on_remove)
		_skip_caches.append(child._on_skip)


func _on_insert(e: Entity) -> bool:
	for insert_fn: Callable in _insert_caches:
		if not insert_fn.call(e):
			return false

	return true


func _on_remove(e: Entity) -> bool:
	for remove_fn: Callable in _remove_caches:
		if not remove_fn.call(e):
			return false

	return true
	
	
func _on_update(_delta: float) -> void:
	var entities: Array[Entity] = EntityMgr.get_valid_entities().filter(
		func(e: Entity) -> bool:
			return not e.is_waiting() and not e.state & Entity.State.DEAD
	)
	
	for e: Entity in entities:
		var is_break: bool = false
		for i: int in _behavior_count:
			var updata_fn: Callable = _update_caches[i]
			
			if updata_fn.call(e):
				for skiped_i: int in range(i + 1, _behavior_count):
					var skip_fn: Callable = _skip_caches[skiped_i]
					skip_fn.call(e)
				
				is_break = true
				break
			
		if not is_break:
			if not e.get_node_or_null(C.CN_SPRITE):
				continue
				
			e.play_animation(e.idle_animation)
			
			
