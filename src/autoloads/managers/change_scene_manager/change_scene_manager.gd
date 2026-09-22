extends Node
## 切换场景管理器。
##
## 负责切换场景与相关操作。


signal loading_progress(percent: float)


@export var finish_wait_time: float = 0.1
@export var loading_screen_scene: PackedScene = null

var _target_scene_path: String = ""


func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED


func _process(_delta: float):
	var progress: Array = []
	var status: int = ResourceLoader.load_threaded_get_status(_target_scene_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			loading_progress.emit(progress[0])
		ResourceLoader.THREAD_LOAD_LOADED:
			process_mode = Node.PROCESS_MODE_DISABLED
			
			var packed_scene: PackedScene = ResourceLoader.load_threaded_get(_target_scene_path)
			Log.debug("切换场景: %s\n" % ResourceUID.uid_to_path(_target_scene_path))
			get_tree().change_scene_to_packed(packed_scene)


func enter_scene(scene_path: String):
	_target_scene_path = scene_path
	
	get_tree().change_scene_to_packed(loading_screen_scene)
	
	process_mode = Node.PROCESS_MODE_INHERIT
	ResourceLoader.load_threaded_request(_target_scene_path, "", true)
	AudioManager.cleanup()
	TimeManager.cleanup()