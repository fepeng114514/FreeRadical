@tool
extends EditorScript
## 更新音频路径的工具。


## 音频资产目录路径。
const AUDIO_ASSETS_DIR_PATH: String = "res://assets/audios/"


## 音频路径数组。
var audio_path_data: AudioPathData = AudioPathData.new()


func _run() -> void:
	for file: String in U.get_files_from_nested_directory(AUDIO_ASSETS_DIR_PATH, "*.ogg"):	
		audio_path_data.audio_path_dict[file.get_file().get_basename()] = file
		Log.verbose("处理 %s" % file)
		
	ResourceSaver.save(audio_path_data, "res://assets/audio_path_data.tres")
