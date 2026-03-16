extends Node

## 主音频总线
const master_bus: StringName = "Master"
## 音乐总线
const music_bus: StringName = "Music"
## 音效总线
const sfx_bus: StringName = "SFX"

var _audio_resources: Dictionary[String, AudioStream] = {}
## 音乐的 AudioStreamPlayer
var _music_player := AudioStreamPlayer.new()
## 音效 AudioStreamPlayer 总数
var _sfx_playe_count: int = 10
## 音效的 AudioStreamPlayer 数组
var _sfx_playes: Array[AudioStreamPlayer] = []

func _ready() -> void:
	_load_audio_resources()
	_init_music_player()
	_init_sfx_players()
	
	
## 加载音频资源
func _load_audio_resources() -> void:
	for audio_path: String in U.load_json("res://datas/audio_paths.json"):
		if not ResourceLoader.exists(audio_path):
			Log.error("未找到音频资源: %s" % audio_path)
			return
			
		var stream: AudioStream = load(audio_path)
		var uid: String = ResourceUID.path_to_uid(audio_path)
		
		_audio_resources[uid] = stream

	
## 初始化音乐
func _init_music_player() -> void:
	_music_player.name = "Music"
	add_child(_music_player)


## 初始化音效
func _init_sfx_players() -> void:
	for i: int in range(_sfx_playe_count):
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.name = "SFX%d" % (i + 1)
		add_child(sfx_player)
		

## 播放音乐
func play_music(uid: String) -> void:
	play_audio(uid)


## 播放音效
func play_sfx(uid: String) -> void:
	for sfx_playe: AudioStreamPlayer in _sfx_playes:
		if sfx_playe.playing:
			continue
		
		play_audio(uid)
		
		
## 播放音频
func play_audio(uid: String) -> void:
	var stream: AudioStream = _audio_resources[uid]
	_music_player.stream = stream
	_music_player.play()
