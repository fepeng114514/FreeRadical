extends Node


## 伤害队列。
var damage_queue: Array[Damage] = []


func clear() -> void:
	damage_queue.clear()


## 插入伤害。
func queue_insert_damage(damage: Damage) -> void:
	damage_queue.append(damage)
