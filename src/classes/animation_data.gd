extends RefCounted
class_name AnimationData
## 动画数据。
## 
## [AnimationData] 用于存储动画相关的数据。


## 动画方向。
var direction: Constants.Direction = Constants.Direction.DOWN
## 是否水平翻转。
var flip_h: bool = false
## 动画名称。
var anim_name: StringName = &""
