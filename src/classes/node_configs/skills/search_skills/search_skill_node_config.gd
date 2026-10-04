@abstract
@tool
extends SkillNodeConfig
class_name SearchSkillNodeConfig
## 搜索技能节点配置资源基类。


## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v):
		Utils.rebind_changed(searcher, v, emit_changed)
		searcher = v
		emit_changed()