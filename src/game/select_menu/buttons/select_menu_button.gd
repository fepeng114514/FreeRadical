extends Control
class_name SelectMenuButton


@export var disabled_color := Color(0.725, 0.725, 0.725)

@export_group("Ref")
@export var button: Button = null
@export var glow: TextureRect = null

var disabled: bool = false
## 选择菜单引用
var select_menu: TowerUpgradeSelectMenu = null
## 选择的实体
var selected_entity: Entity = null
var preview_entity_scene: String = ""
var preview_entity: Entity = null


func _ready() -> void:
	button.pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	glow.visible = false
		
	_update()
		
		
func _process(_delta: float) -> void:
	if not selected_entity:
		return
	
	_update()
		
		
func _update() -> void: pass

		
func _disable() -> void:
	if disabled:
		return

	disabled = true
	button.disabled = true
	modulate = disabled_color
	
	
func _enable() -> void:
	if not disabled:
		return

	disabled = false
	button.disabled = false
	modulate = Color.WHITE

	
func _on_mouse_entered() -> void:
	if disabled:
		return
	
	glow.visible = true
	
	if preview_entity_scene:
		if selected_entity:
			selected_entity.visible = false
			preview_entity = EntityManager.create_entity(preview_entity_scene)
			preview_entity.global_position = selected_entity.global_position
			
			EntityManager.queue_insert_entity(preview_entity)
	
	
func _on_mouse_exited() -> void:
	glow.visible = false

	_hide_preview()
		
		
func _on_pressed() -> void: 
	_hide_preview()


func _hide_preview() -> void:
	if preview_entity:
		EntityManager.queue_remove_entity(preview_entity)
		preview_entity = null
		
		if selected_entity:
			selected_entity.visible = true
	
	
