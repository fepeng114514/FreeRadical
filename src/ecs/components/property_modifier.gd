extends Resource
class_name PropertyModifier


## 修改的类型枚举
enum Type {
	## 加法
	ADD, 
	## 百分比加法
	ADD_PERCENT, 
	## 乘法
	MULTIPLY,
}


## 修改的类型
##
## Type 决定了 ModifierComponent 如何修改实体的属性，例如 ADD 会直接增加属性值，而 MULTIPLY 会乘以一个系数。
@export var type: Type = Type.ADD
## 修改的属性
@export var property: String = ""
## 节点路径
@export var node_path: NodePath = ^""
## 修改的数值
@export var value: float = 0


func apply(base_value: float) -> float:
	match type:
		Type.ADD:
			return base_value + value
		Type.ADD_PERCENT:
			return base_value * (1 + value)
		Type.MULTIPLY:
			return base_value * value

	return base_value