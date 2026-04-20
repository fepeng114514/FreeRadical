extends Node2D
class_name TowerSubentityGroup


## 子实体组进行远程攻击轮换的间隔
@export var attack_loop_time: float = 0
## 子实体组攻击的实体索引
var attack_entity_idx: int = 0
## 上次子实体组进行攻击的时间戳
var last_attack_ts: float = 0
