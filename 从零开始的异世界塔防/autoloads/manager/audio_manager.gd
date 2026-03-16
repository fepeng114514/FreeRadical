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
func play_music(audio_data: AudioData) -> void:
	play_audio(audio_data, _music_player)


## 播放音效
func play_sfx(audio_data: AudioData) -> void:
	for sfx_playe: AudioStreamPlayer in _sfx_playes:
		if sfx_playe.playing:
			continue
		
		play_audio(audio_data, sfx_playe)
		return
		
		
## 播放音频
func play_audio(
		audio_data: AudioData, player: AudioStreamPlayer
	) -> void:
	match audio_data.play_mode:
		C.AudioPlayMode.RANGDOM:
			var stream_uid: String = audio_data.audio_list.pick_random()
			_play(stream_uid, player, audio_data)
		C.AudioPlayMode.CONCURRENCY:
			for stream_uid: String in audio_data.audio_list.pick_random():
				_play(stream_uid, player, audio_data)


## 播放音频
func _play(
		stream_uid: String, 
		player: AudioStreamPlayer, 
		audio_data: AudioData
	) -> void:
	var stream: AudioStream = _audio_resources[stream_uid]
	player.stream = stream
	player.volume_db = audio_data.volume_db
	player.volume_linear = audio_data.volume_linear
	player.play()
