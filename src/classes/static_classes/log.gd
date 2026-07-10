@tool
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


## 发布版本日志级别（低于此级别的日志不会输出）
const release_log_level: LogLevel = LogLevel.INFO
## 调试版本日志级别（低于此级别的日志不会输出）
const debug_log_level: LogLevel = LogLevel.VERBOSE

## 日志级别键数组。
static var log_level_keys: Array = LogLevel.keys()


## 内部日志方法。
static func _log(level: int, message: String) -> void:
	var log_level: LogLevel = release_log_level if OS.has_feature("release") else debug_log_level
	if level < log_level:
		return

	var datetime: String = Time.get_datetime_string_from_system()
	datetime = datetime.split("T")[1]

	var format_message: String = "[%s]%s: %s" % [
		datetime, 
		log_level_keys[level],
		message
	]
	
	match level:
		LogLevel.WARN:
			print_rich("[color=#F1C40F]● WARN: %s[/color]" % format_message)
			push_warning(format_message)
		LogLevel.ERROR:
			var stack: Array = get_stack()

			var sliced: Array = stack.slice(2)
			var result: Array = [
				"Traceback:"
			]

			for item: Dictionary in sliced:
				result.append("\t%s:%s: in func '%s'" % [item.source, item.line, item.function])

			var stack_message: String = "\n".join(result)

			printerr(format_message)
			print(stack_message + "\n")
			push_error(format_message)
		_:
			print(format_message)


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
