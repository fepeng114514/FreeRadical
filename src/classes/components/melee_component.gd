@tool
@icon("res://assets/dpi_textures/at-icons/node2d/sword.svg")
extends Component
class_name MeleeComponent
## 近战组件
##
## MeleeComponent 可以使实体拥有近战技能与拦截的能力，每个近战近战以 [MeleeSkill] 资源子节点的形式存在。[br][br]
## 若 [member is_blocker] 为 [code]true[/code] 作为拦截者：搜索并标记被拦截者，前往第一个被拦截者的近战位置。[br]
## 若 [member is_blocker] 为 [code]false[/code] 作为被拦截者：如果是第一个被拦截等待拦截者到达近战位置，如果拦截者的 [member is_passive] 为 [code]true[/code] 则主动前往拦截者的近战位置。


@warning_ignore_start("unused_signal")
## 近战技能释放后发出。
signal melee_skill_used(skill: MeleeSkill)
## 近战技能冷却后发出。
signal start_melee_skill_cooldown(skill: MeleeSkill)
@warning_ignore_restore("unused_signal")


## 近战状态枚举
enum MeleeState {
	## 近战状态：到达原位置。
	ORIGINAL_POSITION_ARRIVED,
	## 近战状态：返回位置中。
	ORIGINAL_POSITION_MOVING,      
	## 近战状态：已到达位置。
	MELEE_POSITION_ARRIVED,    
	## 近战状态：前往近战位置中。
	MELEE_POSITION_MOVING,  
}


@export var config: MeleeComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 是否是拦截者。
var is_blocker: bool = false
## 拦截者 ID 列表
var blocker_id_list := PackedInt32Array()
## 拦截数量，根据被拦截者的拦截成本计算。
var blocked_count: int = 0
## 被拦截者 ID 列表。
var blocked_id_list := PackedInt32Array()
## 是额外拦截者。
var is_extra_blocker: bool = false
## 原始全局位置。
var original_global_position := Vector2.ZERO
## 近战全局位置。
var melee_global_position := Vector2.ZERO
## 移动速度（向量）。
var velocity := Vector2.ZERO
## 近战状态。
var melee_state: MeleeState = MeleeState.ORIGINAL_POSITION_ARRIVED


func _draw() -> void:
	if not config:
		return
		
	if DebugManager.draw_range_enabled:
		if config.searcher:
			config.searcher.draw_search_range(self, position)

	if DebugManager.draw_offset_enabled:
		if config.melee_position_offsets:
			config.melee_position_offsets.draw_offset_group(self)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()
	
	if not get_children():
		warnings.append("请至少增加一个 MeleeSkill 或其类型的子节点，否则实体无法释放近战技能。")
	
	return warnings

	
## 拦截者绑定拦截关系。
func blocker_bind_melee_relations(blocker_id: int, blocked_id: int) -> void: 
	var blocked: Entity = EntityManager.get_entity_by_id(blocked_id)
	var blocked_melee_c: MeleeComponent = blocked.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	
	blocked_melee_c.blocker_id_list.append(blocker_id)
	blocked_id_list.append(blocked_id)
	blocked_count += blocked_melee_c.config.block_cost


## 被拦截者绑定拦截关系。
func blocked_bind_melee_relations(blocker_id: int, blocked_id: int) -> void: 
	var blocker: Entity = EntityManager.get_entity_by_id(blocker_id)
	var blocker_melee_c: MeleeComponent = blocker.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	
	blocker_id_list.append(blocker_id)
	blocker_melee_c.blocked_id_list.append(blocked_id)
	blocker_melee_c.blocked_count += config.block_cost


## 拦截者解除拦截关系。
func blocker_unbind_melee_relations(entity: Entity) -> void:
	for blocked_id: int in blocked_id_list:
		var blocked: Entity = EntityManager.get_entity_by_id(blocked_id)
		var blocked_melee_c: MeleeComponent = blocked.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
		blocked_melee_c.blocker_id_list.erase(entity.id)
		
	blocked_id_list.clear()
	blocked_count = 0
	melee_state = MeleeState.ORIGINAL_POSITION_ARRIVED
	is_extra_blocker = false


## 被拦截者解除拦截关系。
func blocked_unbind_melee_relations(entity: Entity) -> void:
	for blocker_id: int in blocker_id_list:
		var blocker: Entity = EntityManager.get_entity_by_id(blocker_id)
		var blocker_melee_c: MeleeComponent = blocker.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
		blocker_melee_c.blocked_id_list.erase(entity.id)
	
	blocker_id_list.clear()


## 拦截者清理无效拦截关系。
func blocker_cleanup_melee_relations(entity: Entity) -> void:
	var center: Vector2 = entity.global_position
	var rally_c: RallyComponent = entity.get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
	if rally_c:
		center = rally_c.rally_center_global_position

	var new_blockeds_ids := PackedInt32Array()
	blocked_count = 0
	
	for id: int in blocked_id_list:
		var blocked: Entity = EntityManager.get_entity_by_id(id)
		if not blocked:
			continue 
			
		if not MathUtils.is_in_ellipse_ring(
				center, blocked.global_position, config.searcher.min_radius, config.searcher.max_radius
			):
			continue
			
		var b_melee_c: MeleeComponent = blocked.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
		
		new_blockeds_ids.append(id)
		blocked_count += b_melee_c.config.block_cost
		
	blocked_id_list = new_blockeds_ids


## 被拦截者清理无效拦截关系。
func blocked_cleanup_melee_relations(_e: Entity) -> void:
	var new_blockers_ids := PackedInt32Array()
	
	for id: int in blocker_id_list:
		var blocker: Entity = EntityManager.get_entity_by_id(id)
		if not blocker:
			continue 
			
		new_blockers_ids.append(id)
		
	blocker_id_list = new_blockers_ids
