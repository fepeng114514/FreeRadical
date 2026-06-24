@tool
extends Component
class_name MeleeComponent
## 近战组件
##
## MeleeComponent 可以使实体拥有近战技能与拦截的能力，每个近战近战以 [MeleeSkill] 资源子节点的形式存在。[br][br]
## 若 [member is_blocker] 为 true 作为拦截者：搜索并标记被拦截者，前往第一个被拦截者的近战位置。[br]
## 若 [member is_blocker] 为 false 作为被拦截者：如果是第一个被拦截等待拦截者到达近战位置，如果拦截者的 [member is_passive] 为 true 则主动前往拦截者的近战位置。


## 近战状态枚举
enum MeleeState {
	## 近战状态：到达原点。
	ORIGIN_POS_ARRIVED,
	## 近战状态：返回位置中。
	ORIGIN_POS_MOVING,      
	## 近战状态：已到达位置。
	MELEE_POS_ARRIVED,    
	## 近战状态：前往近战位置中。
	MELEE_POS_MOVING,  
}


## 是否不主动前往近战位置。
@export var is_passive: bool = false
## 移动速度。
@export var speed: float = 100
## 移动动画组。
@export var motion_animation: AnimationGroup = null
## 近战位置偏移组。
@export var melee_pos_offsets: OffsetGroup = null:
	set(v): 
		melee_pos_offsets = v
		U.resource_redraw_setter(self, melee_pos_offsets)
## 到达位置的阈值。
@export var arrived_distance: float = 10

@export_group("Blocker")
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null
## 最大被拦截者数量。
@export var max_blocked_count: int = 1

@export_group("Blocked")
## 拦截成本。
@export var block_cost: int = 1

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
## 原位置。
var origin_pos := Vector2.ZERO
## 近战位置。
var melee_pos := Vector2.ZERO
## 移动速度（向量）。
var velocity := Vector2.ZERO
## 近战状态。
var melee_state: MeleeState = MeleeState.ORIGIN_POS_ARRIVED


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
		
	if Engine.is_editor_hint():
		U.connect_resource_changed(melee_pos_offsets, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if searcher:
			searcher.draw(self, position)
		OffsetGroup.draw_offset_group(self, melee_pos_offsets)
	
	
func _get_configuration_warnings() -> PackedStringArray:
	var warn: PackedStringArray = []
	
	if not get_children():
		warn.append("请至少增加一个 MeleeSkill 或其类型的子节点，否则实体无法释放近战技能。")
	
	return warn

	
## 绑定拦截关系。
func bind_melee_relations(blocker_id: int, blocked_id: int) -> void: 
	if is_blocker:
		var blocked: Entity = EntityMgr.get_entity_by_id(blocked_id)
		var blocked_melee_c: MeleeComponent = blocked.get_node_or_null(C.CN_MELEE)
		
		blocked_melee_c.blocker_id_list.append(blocker_id)
		blocked_id_list.append(blocked_id)
		blocked_count += blocked_melee_c.block_cost
	else:
		var blocker: Entity = EntityMgr.get_entity_by_id(blocker_id)
		var blocker_melee_c: MeleeComponent = blocker.get_node_or_null(C.CN_MELEE)
		
		blocker_id_list.append(blocker_id)
		blocker_melee_c.blocked_id_list.append(blocked_id)
		blocker_melee_c.blocked_count += block_cost


## 解除拦截关系。
func unbind_melee_relations(erase_id: int) -> void:
	if is_blocker:
		for blocked_id: int in blocked_id_list:
			var blocked: Entity = EntityMgr.get_entity_by_id(blocked_id)
			var blocked_melee_c: MeleeComponent = blocked.get_node_or_null(C.CN_MELEE)
			blocked_melee_c.blocker_id_list.erase(erase_id)
			
		blocked_id_list.clear()
		is_extra_blocker = false
	else:
		for blocker_id: int in blocker_id_list:
			var blocker: Entity = EntityMgr.get_entity_by_id(blocker_id)
			var blocker_melee_c: MeleeComponent = blocker.get_node_or_null(C.CN_MELEE)
			blocker_melee_c.blocked_id_list.erase(erase_id)
		
		blocker_id_list.clear()


## 清理无效拦截关系。
func cleanup_melee_relations(e: Entity) -> void:
	if is_blocker:
		var center: Vector2 = e.global_position
		var rally_c: RallyComponent = e.get_node_or_null(C.CN_RALLY)
		if rally_c:
			var rally_center_position: Vector2 = rally_c.rally_center_position
			
			if rally_center_position != Vector2.ZERO:
				center = rally_center_position

		var new_blockeds_ids := PackedInt32Array()
		blocked_count = 0
		
		for id: int in blocked_id_list:
			var blocked: Entity = EntityMgr.get_entity_by_id(id)
			if not U.is_valid_entity(blocked) :
				continue 
				
			if not U.is_in_ring(
					center, blocked.global_position, searcher.min_radius, searcher.max_radius
				):
				continue
				
			var b_melee_c: MeleeComponent = blocked.get_node_or_null(C.CN_MELEE)
			
			new_blockeds_ids.append(id)
			blocked_count += b_melee_c.block_cost
			
		blocked_id_list = new_blockeds_ids
	else:
		var new_blockers_ids := PackedInt32Array()
		
		for id: int in blocker_id_list:
			var blocker: Entity = EntityMgr.get_entity_by_id(id)
			if not U.is_valid_entity(blocker):
				continue 
				
			new_blockers_ids.append(id)
			
		blocker_id_list = new_blockers_ids
