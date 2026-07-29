@tool
extends EditorScript
## 生成音频路径数据的工具。


## 音频资产目录路径。
const AUDIO_ASSETS_DIR_PATH: String = "res://assets/audios/"


var audio_path_data: AudioPathData = null


func _run() -> void:
	audio_path_data = AudioPathData.new()

	for file: String in U.get_files_from_nested_directory(AUDIO_ASSETS_DIR_PATH, "*.ogg"):	
		var audio_basename: String = file.get_file().get_basename()
		audio_path_data.audio_path_dict[audio_basename] = file

		var audio_uid: String = ResourceUID.path_to_uid(file)
		audio_path_data.audio_uid_dict[audio_basename] = audio_uid
		Log.verbose("增加音频路径 %s, UID: %s" % [audio_basename, audio_uid])
		
	ResourceSaver.save(audio_path_data, "res://assets/audio_path_data.tres")
