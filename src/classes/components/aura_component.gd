extends Component
class_name AuraComponent
## 光环组件。
## 
## AuraComponent 可以使实体可周期性对范围内其他实体造成影响。


## 光环类型枚举。
enum Type {
	## 光环类型: 无。
	NONE = 0,
	## 光环类型: 正面效果。
	BUFF = 1,
	## 光环类型: 负面效果。
	DEBUFF = 1 << 1,
}


## 是否跟随目标。
@export var track_target: bool = true
## 相同处理资源。
@export var same_process: SameProcessResource = null
## 是否移除被禁止的光环。
@export var remove_banned: bool = true
## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v): 
		influence = v
		Utils.resource_redraw_setter(self, influence)
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v): 
		searcher = v
		Utils.resource_redraw_setter(self, searcher)

@export_group("Cycle")
## 周期时间。
@export var cycle_time: float = 1.0
## 最大周期数。
@export var max_cycle: int = Constants.UNSET

## 当前周期数。
var current_cycle: int = 0
## 时间戳。
var ts: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

	if Engine.is_editor_hint():
		Utils.connect_resource_changed(searcher, queue_redraw)
		Utils.connect_resource_changed(influence, queue_redraw)


func _validate_property(property: Dictionary):
	match property.name:
		"aura_type":
			property.hint_string = "mask_check(%s)" % Type


func _draw() -> void:
	if Engine.is_editor_hint():
		if searcher:
			searcher.draw(self, position)
		
		if influence:
			influence.draw(self, position)
