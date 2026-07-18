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


## 音效 [AudioStreamPlayer] 总数。
var _sfx_player_count: int = 10

## 音效的 [AudioStreamPlayer] 数组。
var _sfx_player_list: Array[AudioStreamPlayer] = []
## 音乐的 [AudioStreamPlayer]。
var _music_player := AudioStreamPlayer.new()


func _ready() -> void:
	# 初始化音乐
	_music_player.name = "Music"
	add_child(_music_player)
	
	# 初始化音效
	for i: int in _sfx_player_count:
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.name = "SFX%d" % (i + 1)
		add_child(sfx_player)
		_sfx_player_list.append(sfx_player)
	
	
## 播放音频数据内的音乐。
func play_music(audio_data: AudioGroup) -> void:
	play_audio(audio_data, _music_player, MusicBus)


## 播放音频数据内的音效。
func play_sfx(audio_data: AudioGroup) -> void:
	if not audio_data:
		return
	
	for sfx_player: AudioStreamPlayer in _sfx_player_list:
		if sfx_player.playing:
			continue

		play_audio(audio_data, sfx_player, SFXBus)
		return
		
		
## 播放音频数据内的音频。
func play_audio(
		audio_data: AudioGroup, player: AudioStreamPlayer, bus: StringName
	) -> void:
	if not audio_data:
		return
		
	await TimeMgr.y_wait(audio_data.delay)
	
	var play_list: Array[AudioStream] = []
	var data_list: Array[AudioStream] = audio_data.list

	match audio_data.play_mode:
		AudioPlayMode.RANDOM:
			var stream: AudioStream = U.pick_random(data_list)
			play_list = [stream]
		AudioPlayMode.SEQUENCE:
			var play_idx: int = audio_data.played_idx + 1
			play_idx %= data_list.size()
			
			var stream: AudioStream = data_list[play_idx]
			audio_data.played_idx = play_idx
			
			play_list = [stream]
		AudioPlayMode.CONCURRENCY:
			play_list = data_list
			
	for stream: AudioStream in play_list:
		player.stream = stream
		player.volume_db = audio_data.volume_db
		player.volume_linear = audio_data.volume_linear
		player.bus = bus
		player.play()
