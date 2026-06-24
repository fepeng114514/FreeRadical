extends Component
class_name ExperienceComponent
## 经验组件。
##
## ExperienceComponent 可以使实体拥有等级与经验的能力，等级与经验以 [Stat] 子节点的形式存在。
## @deprecated
## @deprecated: 未实现。


## 实体等级。
@export var level: int = 1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED