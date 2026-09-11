@tool
@abstract
extends Object
class_name Log
## 日志库。
##
## 存储了一些日志方法，用于在代码中进行日志输出。


## 日志级别枚举。
enum LogLevel {
	## 日志级别：详细信息。
	VERBOSE = 0,
	## 日志级别：调试信息。
	DEBUG = 1,
	## 日志级别：普通信息。
	INFO = 2,
	## 日志级别：警告。
	WARN = 3,
	## 日志级别：错误。
	ERROR = 4,
}
## 日志级别键数组。
const log_level_keys: Array[String] = [
	"VERBOSE",
	"DEBUG",
	"INFO",
	"WARN",
	"ERROR",
]
## 日志级别颜色数组。
const log_level_colors: Array[String] = [
	"#95A5A6",
	"#1ABC9C",
	"#3498DB",
	"#F39C12",
	"#E74C3C",
]

## 发布版本日志级别（低于此级别的日志不会输出）
const release_log_level: LogLevel = LogLevel.INFO
## 调试版本日志级别（低于此级别的日志不会输出）
const debug_log_level: LogLevel = LogLevel.VERBOSE


## 内部日志方法。
static func _log(level: int, message: String) -> void:
	var log_level: LogLevel = debug_log_level if OS.is_debug_build() else release_log_level
	if level < log_level:
		return

	var datetime: String = Time.get_datetime_string_from_system().split("T")[1]

	var stack: Array = get_stack()
	var current_frame: Dictionary = stack[2]
	var current_source: String = current_frame.source

	var format_message: String = "[%s][%s][%s:%s] %s" % [
		datetime, 
		log_level_keys[level],
		current_source.get_file().get_basename(),
		current_frame.function,
		message
	]

	print_rich("[color=%s]%s[/color]" % [log_level_colors[level], format_message])

	match level:
		LogLevel.WARN:
			push_warning(format_message)
		LogLevel.ERROR:
			assert(false, format_message)
			

## 打印详细日志。
static func verbose(message: String) -> void:
	_log(LogLevel.VERBOSE, message)


## 打印调试日志。
static func debug(message: String) -> void:
	_log(LogLevel.DEBUG, message)


## 打印信息日志。
static func info(message: String) -> void:
	_log(LogLevel.INFO, message)


## 打印警告日志。
static func warn(message: String) -> void:
	_log(LogLevel.WARN, message)


## 打印错误日志。
static func error(message: String) -> void:
	_log(LogLevel.ERROR, message)
