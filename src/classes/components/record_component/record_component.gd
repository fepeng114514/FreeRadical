@tool
extends Component
class_name RecordComponent
## 记录组件。
##
## [RecordComponent] 用于存储跨实体的记录信息，当前实体创建实体时会自动传递子记录节点数据。[br][br]
## [b]注意[/b]：如果创建的实体没有相应的记录节点将不会传递数据。


func transmit_record(other_record_c: RecordComponent) -> void:
	for record: Record in get_children():
		var new_record: Record = other_record_c.get_node_or_null(String(record.name))
		if not new_record:
			continue

		new_record.transmit_record(record)
		
