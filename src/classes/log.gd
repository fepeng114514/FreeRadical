@tool
class_name Log
## 日志库


static var log_level_keys: Array = C.LogLevels.keys()


## 内部日志方法
static func _log(level: int, message: String) -> void:
	if level < Conf.LOG_LEVEL:
		return

	var datetime: String = Time.get_datetime_string_from_system()
	datetime = datetime.split("T")[1]

	var format_message: String = "[%s]%s: %s" % [
		datetime, 
		log_level_keys[level],
		message
	]
	
	match level:
		C.LogLevels.WARN:
			print_rich("[color=#F1C40F]● WARN: %s[/color]" % format_message)
			push_warning(format_message)
		C.LogLevels.ERROR:
			var stack: Array = get_stack()

			var sliced: Array = stack.slice(3)
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


## 详细日志
static func verbose(message: String) -> void:
	_log(C.LogLevels.VERBOSE, message)


## 调试日志
static func debug(message: String) -> void:
	_log(C.LogLevels.DEBUG, message)


## 信息日志
static func info(message: String) -> void:
	_log(C.LogLevels.INFO, message)


## 警告日志
static func warn(message: String) -> void:
	_log(C.LogLevels.WARN, message)


## 错误日志
static func error(message: String) -> void:
	_log(C.LogLevels.ERROR, message)
