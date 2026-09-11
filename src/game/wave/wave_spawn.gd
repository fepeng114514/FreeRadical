extends Resource
class_name WaveSpawn
## 生成组资源。


## 生成下一个实体间隔（秒）。
@export var interval: float = 1.0
## 生成的实体场景路径。
@export_file("*.tscn") var entity: String = ""
## 生成的路径，-1 表示随机。
@export var pathway_index: int = Constants.UNSET
## 生成的子路径，-1 表示随机。
@export var sub_pathway_index: int = Constants.UNSET
## 生成的间隔，单位为秒。
@export var spawn_interval: float = 1.0
## 生成的数量。
@export var count: int = 10
## 实体是否启用沿相反路径移动。
@export var reversed_enabled: bool = false
## 实体到达终点是否启用循环移动。
@export var loop_enabled: bool = false
