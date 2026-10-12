@abstract
extends Object
class_name DictionaryUtils
## 字典工具类。
##
## [DictionaryUtils] 是一个字典工具类，用于在代码中进行字典操作的辅助函数。


## 获取两个字典的对称差集。
static func get_dict_sysmetric_diff(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	var diff: Dictionary = {}

	for key in dict1:
		diff[key] = dict1[key]

	for key in dict2:
		if diff.erase(key):
			continue
			
		diff[key] = dict2[key]
		
	return diff


## 获取两个字典相对于另一个字典的差集数组，索引 0 为 [param dict1] 相对于 [param dict2] 的差集，索引 1 为 [param dict2] 相对于 [param dict1] 的差集。
static func get_dict_diffs(dict1: Dictionary, dict2: Dictionary) -> Array[Dictionary]:
	var diff1: Dictionary = {}
	var diff2: Dictionary = {}

	for key in dict1:
		diff1[key] = dict1[key]

	for key in dict2:
		if diff1.erase(key):
			continue
			
		diff2[key] = dict2[key]
		
	return [diff1, diff2]
