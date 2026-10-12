@tool
extends Component
class_name ExperienceComponent
## 经验组件。
##
## [ExperienceComponent] 可以让实体拥有经验，实体获得一定经验后等级会提升。
## @deprecated
## @deprecated: 未实现。


@export var config: ExperienceComponentNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()
