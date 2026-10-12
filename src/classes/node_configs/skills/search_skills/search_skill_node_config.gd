@abstract
@tool
extends SkillNodeConfig
class_name SearchSkillNodeConfig
## 搜索技能节点配置资源基类。
##
## [SearchSkillNodeConfig] 是所有搜索技能配置节点的基类，包含了搜索技能的基本配置属性。


## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v):
		Utils.rebind_changed(searcher, v, emit_changed)
		searcher = v
		emit_changed()