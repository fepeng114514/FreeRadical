extends Node
## 音频管理器。
##
## 负责管理音频与相关操作。


## 音频播放模式枚举。
enum AudioPlayMode {
	## 音频播放模式：随机播放音频列表中的音频。
	RANDOM,
	## 音频播放模式：按顺序选择并播放音频列表中的音频。
	SEQUENCE,
	## 音频播放模式：并行播放音频列表中的音频。
	CONCURRENCY
}


## 主音频总线。
const MasterBus: StringName = &"Master"
## 音乐总线。
const MusicBus: StringName = &"Music"
## 音效总线。
const SFXBus: StringName = &"SFX"


## 音效播放器总数。
var _sfx_player_count: int = 10
## 音效播放器数组。
var _sfx_player_list: Array[AudioStreamPlayer] = []
## 音乐播放器。
var _music_player := AudioStreamPlayer.new()
## 下一个音效播放器索引。
var _next_sfx_index: int = 0
## 音频资源缓存。
var _audio_resources_caches: Dictionary[String, AudioStream] = {}


func _ready() -> void:
	_music_player.name = "Music"
	add_child(_music_player)
	
	for player_index: int in _sfx_player_count:
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.name = "SFX%d" % (player_index + 1)
		add_child(sfx_player)
		_sfx_player_list.append(sfx_player)


## 清理音频管理器。
func cleanup() -> void:
	_next_sfx_index = 0
	
	stop_music()
	stop_sfx()
	
	_audio_resources_caches.clear()
	
	
## 播放音频数据内的音乐。
func play_music(audio_data: AudioGroup) -> void:
	play_audio(audio_data, _music_player, MusicBus)


## 播放音频数据内的音效。
func play_sfx(audio_data: AudioGroup) -> void:
	if not audio_data:
		return
	
	var player := _sfx_player_list[_next_sfx_index]
	_next_sfx_index = (_next_sfx_index + 1) % _sfx_player_count
	
	play_audio(audio_data, player, SFXBus)
		
		
## 播放音频数据内的音频。
func play_audio(
		audio_data: AudioGroup, player: AudioStreamPlayer, bus: StringName
	) -> void:
	if not audio_data:
		return
		
	await TimeManager.y_wait(audio_data.delay)
	
	var play_list := PackedStringArray()
	var data_list: PackedStringArray = audio_data.list
	
	match audio_data.play_mode:
		AudioPlayMode.RANDOM:
			var stream_path: String = ArrayUtils.pick_random(data_list)
			play_list = [stream_path]
			
		AudioPlayMode.SEQUENCE:
			var play_index: int = audio_data.played_index + 1
			play_index %= data_list.size()
			
			var stream_path: String = data_list[play_index]
			audio_data.played_index = play_index
			
			play_list = [stream_path]
		AudioPlayMode.CONCURRENCY:
			play_list = data_list
			
	for stream_path: String in play_list:
		var stream: AudioStream = load(stream_path)
		_audio_resources_caches[stream_path] = stream
		player.stream = stream
		player.volume_db = audio_data.volume_db
		player.volume_linear = audio_data.volume_linear
		player.bus = bus
		player.play()


func stop_music() -> void:
	_music_player.stop()


func stop_sfx() -> void:
	for sfx_player: AudioStreamPlayer in _sfx_player_list:
		sfx_player.stop()
