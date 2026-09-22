@tool
extends BaseRangedSkill
class_name RangedSkill
## 单次远程技能节点。
##
## RangedSkill 会生成一个子弹，以子弹作为中介，对目标造成影响。子弹会以特定轨迹飞行，到达目标后造成影响。


@export var config: RangedSkillNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()