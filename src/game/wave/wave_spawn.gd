extends Resource
class_name WaveSpawn
## 生成组资源。


## 生成下一个实体间隔，单位为秒。
@export var interval: float = 1.0
## 生成的实体场景路径。
@export_file("*.tscn") var entity: String = ""
## 生成的路径，-1 表示随机。
@export var pathway_idx: int = C.UNSET
## 生成的子路径，-1 表示随机。
@export var sub_pathway_idx: int = C.UNSET
## 生成的间隔，单位为秒。
@export var spawn_interval: float = 1.0
## 生成的数量。
@export var count: int = 10
## 实体是否沿相反路径移动。
@export var reversed: bool = false
## 实体到达终点是否循环移动。
@export var loop: bool = false
