extends Resource
class_name SelectMenuButtonData
## 选择菜单项数据资源


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
