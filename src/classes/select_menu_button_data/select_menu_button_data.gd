extends Resource
class_name SelectMenuButtonData
## 选择菜单项数据资源。
##
## [SelectMenuButtonData] 用于存储选择菜单按钮数据，包括按钮的位置、图标、标题、描述和预览实体场景。


## 按钮位置索引。
@export var place: int = 0
## 按钮图标。
@export var icon: Texture2D = null

@export_group("Mouse Hover")
## 悬浮显示的标题。
@export var title: String = ""
## 悬浮显示的描述。
@export var description: String = ""
## 悬浮显示的预览实体场景。
@export_file("*.tscn") var preview_entity_scene: String = ""
