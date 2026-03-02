extends System


func _on_update(_delta: float) -> void:
	#var entities: Array[Entity] = EntityDB.get_entities_group(C.CN_TOWER).filter(
		#func(e: Entity) -> bool:
			#return 
	#)

	for e: Entity in EntityDB.get_entities_group(C.CN_TOWER):
		var subentity_c: SubentityComponent = e.get_c(C.CN_SUBENTITY)
		if not subentity_c:
			continue

		var tower_c: TowerComponent = e.get_c(C.CN_TOWER)

		var target: Entity = EntityDB.search_target(
			tower_c.search_mode, 
			e.global_position, 
			tower_c.max_range, 
			tower_c.min_range, 
			tower_c.vis_flag_bits, 
			tower_c.vis_ban_bits
		)

		for sub_e: Entity in subentity_c.list:
			if not target:
				sub_e.target_id = -1
				continue

			sub_e.target_id = target.id
