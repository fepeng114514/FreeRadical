@tool
extends Record
class_name PriceRecord
## 价格记录组件。
##
## PriceRecord 用于存储跨实体的价格信息。


## 总价格。
var total_price: float = 0.0


func transmit_record(record: PriceRecord) -> void:
	total_price = record.total_price


static func get_not_found_configuration_warnings(p_parent: Node) -> PackedStringArray:
	var warnings := PackedStringArray()

	if p_parent and not p_parent.get_node_or_null(Constants.PRICE_RECORD_NODE_PATH):
		warnings.append("请为实体增加一个 RecordComponent 节点，并为其增加一个 PriceRecord 子节点，否则实体无法存储价格信息。")

	return warnings
