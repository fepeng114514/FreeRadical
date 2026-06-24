extends Component
class_name SpawnerComponent
## 生成器组件。
##
## SpawnerComponent 可以使实体拥有生成其他实体的能力。
## @deprecated
## @deprecated: 未实现。


## 生成器名称。
@export var spawner_name: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED