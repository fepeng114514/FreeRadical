@abstract
extends Object
class_name ArrayUtils
## 数组工具类。


## 交换并删除数组中的元素。[br][br]
## [b]注意[/b]: 交换后，数组顺序会被改变。
static func array_swap_delete(array: Array, index: int) -> void:
	var array_size: int = array.size()
	if array_size == 0:
		return
		
	var element = array.pop_back()
		
	if index == array_size - 1:
		return

	array[index] = element


## 获取两个数组的对称差集。
static func get_array_sysmetric_diff(array1: Array, array2: Array) -> Array:
	var counts: Dictionary[Variant, int] = {}
	var diff: Array = []

	for item in array1:
		counts[item] = counts.get(item, 0) + 1

	for item in array2:
		counts[item] = counts.get(item, 0) + 1

	for item in counts:
		if counts[item] > 1:
			continue

		diff.append(item)

	return diff


## 获取两个数组相对于另一个数组的差集数组，索引 0 为 [param array1] 相对于 [param array2] 的差集，索引 1 为 [param array2] 相对于 [param array1] 的差集。
static func get_array_diffs(array1: Array, array2: Array) -> Array[Array]:
	var counts: Dictionary[Variant, int] = {}
	var array1_has_items: Dictionary[Variant, bool] = {}
	var array2_has_items: Dictionary[Variant, bool] = {}
	var diff1: Array = []
	var diff2: Array = []

	for item in array1:
		counts[item] = counts.get(item, 0) + 1
		array1_has_items[item] = true

	for item in array2:
		counts[item] = counts.get(item, 0) + 1
		array2_has_items[item] = true

	for item in counts:
		if counts[item] > 1:
			continue

		if array2_has_items.has(item):
			diff2.append(item)
		else:
			diff1.append(item)

	return [diff1, diff2]


## 从数组中随机选择一个元素，仅用于从紧缩数组中随机选择一个元素。
static func pick_random(array: Array) -> Variant:
	if array.is_empty():
		return null
		
	return array[randi() % array.size()]