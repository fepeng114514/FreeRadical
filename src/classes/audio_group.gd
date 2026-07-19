extends Resource
class_name AudioGroup
## 音频组资源。


## 播放模式。
@export var play_mode: AudioMgr.AudioPlayMode = AudioMgr.AudioPlayMode.SEQUENCE
## 音频路径列表。
@export_file("*.ogg") var list := PackedStringArray()
## 音量，单位为分贝。
@export var volume_db: float = 0.0
## 音量，线性增长而非对数。
@export var volume_linear: float = 1
## 延迟，单位为秒。
@export var delay: float = 0.0

## 当前播放的索引。
var played_idx: int = -1