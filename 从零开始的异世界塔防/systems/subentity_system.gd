extends System


func _on_create(e: Entity) -> bool:
	var subentity_c: SubentityComponent = e.get_c(C.CN_SUBENTITY)
	
	if not subentity_c:
		return true
		
	for sub_e: Entity in subentity_c.get_children():
		subentity_c.list.append(sub_e)
	
	return true


func _on_insert(e: Entity) -> bool:
	var subentity_c: SubentityComponent = e.get_c(C.CN_SUBENTITY)
	
	if not subentity_c:
		return true
		
	for sub_e: Entity in subentity_c.list:
		sub_e.is_subentity = true
		sub_e.source_id = e.id
		EntityDB.process_create(sub_e)
		sub_e.insert_entity()
		
	return true
	
	
#func _on_update(delta: float) -> void:
