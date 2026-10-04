@tool
@icon("res://assets/dpi_textures/at-icons/node2d/click.svg")
extends Component
class_name SelectComponent
## 选择组件。
##
## SelectComponent 可以使实体被鼠标选择。


## 实体信息栏类型枚举。
enum InfoBarType {
	## 信息栏类型：无，不显示。
	NONE,
	## 信息栏类型：敌人或友军的信息栏。
	UNIT,
	## 信息栏类型：防御塔的信息栏。
	TOWER,
	## 信息栏类型：文本。
	TEXT,
}


@export var config: SelectComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()


func _draw() -> void:
	if not config:
		return
		
	if DebugManager.draw_offset_enabled:
		draw_circle(
			config.select_menu_offset, 
			4,
			Color.GREEN, 
			false,
			1
		)

		if DebugManager.draw_range_enabled:
			if config.can_select:
				var rect := Rect2(config.select_rect.position, config.select_rect.size)
				draw_rect(
					rect, 
					Color(0.2, 0.6, 1.0, 0.25), 
					true
				)
				draw_rect(
					rect, 
					Color(0.2, 0.6, 1.0, 0.9), 
					false, 
					1
				)
	

## 获取全局位置的矩形。
func get_global_select_rect() -> Rect2:
	return Rect2(global_position + config.select_rect.position, config.select_rect.size)


## 检测是否点击在矩形内。
func is_click_at_global_select_rect(clicked_global_position: Vector2) -> bool:
	return (
		config.can_select
		and get_global_select_rect().has_point(clicked_global_position)
	)
