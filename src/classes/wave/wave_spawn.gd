extends Resource
class_name WaveSpawn
## 敌人生成资源


## 生成下一个敌人间隔，单位为秒
@export var interval: float = 1
## 生成的敌人
@export var entity: String = ""
## 生成的路径，-1 表示随机
@export var pathway_idx: int = C.UNSET
## 生成的子路径，-1 表示随机
@export var sub_pathway_idx: int = C.UNSET
## 每个敌人之间的间隔，单位为秒
@export var spawn_interval: float = 1
## 生成总数
@export var count: int = 10
## 敌人是否沿相反路径移动
@export var reversed: bool = false
## 敌人到达终点是否循环（原路返回）
@export var loop: bool = false
