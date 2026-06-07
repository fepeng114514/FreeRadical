extends Resource
class_name PropertyModifier
## 属性修改器资源。
##
## PropertyModifier 用于修改实体的属性值，例如增加、减少、乘以等。


## 修改类型枚举。
enum Type {
	## 修改类型：加法。
	ADD, 
	## 修改类型：百分比加法。
	ADD_PERCENT, 
	## 修改类型：乘法。
	MULTIPLY,
}


## 修改类型。
@export var type: Type = Type.ADD
## 修改的属性。
@export var property: String = ""
## 节点路径。
@export var node_path: NodePath = ^""
## 修改的数值。
@export var value: Variant = 0


## 应用修改。
func apply(base_value: Variant) -> float:
	if value is float:
		match type:
			Type.ADD:
				return base_value + value
			Type.ADD_PERCENT:
				return base_value * (1 + value)
			Type.MULTIPLY:
				return base_value * value

	return base_value
