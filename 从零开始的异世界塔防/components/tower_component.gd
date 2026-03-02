extends Node
class_name TowerComponent


@export var min_range: float = 0
@export var max_range: float = 0
@export var search_mode: C.SEARCH = C.SEARCH.ENTITY_FIRST
@export var vis_flags: Array[C.FLAG] = []:
	set(value): 
		vis_flags = value
		vis_flag_bits = U.merge_flags(value)
@export var vis_bans: Array[C.FLAG] = []:
	set(value): 
		vis_bans = value
		vis_ban_bits = U.merge_flags(value)
@export var whitelist_tag: Array[C.ENTITY_TAG] = []
@export var blacklist_tag: Array[C.ENTITY_TAG] = []

var vis_flag_bits: int = 0
var vis_ban_bits: int = 0
