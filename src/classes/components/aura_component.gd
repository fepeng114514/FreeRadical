extends Component
class_name AuraComponent
## 光环组件
## 
## AuraComponent 可以使实体可周期性对范围内其他实体造成影响


@export_group("Cycle")
## 周期时间
@export var cycle_time: float = 1
## 最大周期数
@export var max_cycle: int = C.UNSET
@export var search: SearchResource = null:
	set(value):
		search = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(search, queue_redraw)
			queue_redraw()
@export var influence: InfluenceResource = null:
	set(value):
		influence = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(influence, queue_redraw)
			queue_redraw()
@export var same_process: SameProcessResource = null
## 是否移除被禁止的光环
@export var remove_banned: bool = true

## 当前周期数
var curren_cycle: int = 0
## 时间戳
var ts: float = 0


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(search, queue_redraw)
		U.connect_resource_changed(influence, queue_redraw)


func _validate_property(property: Dictionary):
	match property.name:
		"aura_type":
			property.hint_string = "mask_enum:AuraType"


func _draw() -> void:
	if Engine.is_editor_hint():
		if search:
			search.draw(self, position)
		
		if influence:
			influence.draw(self, position)
