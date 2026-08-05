extends Resource
class_name SpriteFramesData


## 图层数量，如果大于 0 会生成对应数量的 [SpriteFrames] 资源，[br]
## 每个资源名称末尾会拼接当前的层数，[br][br]
## [b]例如[/b]：图层数量为 2，那么将会生成 2 个 [SpriteFrames] 资源，名称分别为`资源名1`、`资源名2`。
@export var layer_count: int = 0
## 动画列表。
@export var animation_dict: Dictionary[String, SpriteFramesAnimationData] = {}
