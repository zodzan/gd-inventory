class_name Bag
extends Node


class Slot extends Object:
	signal item_set(item: Node)
	signal item_removed(item: Node)
	
	var item: Node : set = set_item, get = get_item
	var parent: Node : set = set_parent, get = get_parent 

	
	func set_item(node: Node) -> void:
		if is_instance_valid(item):
			clear_item()
		
		_add_to_scene(node)
		item = node
		
		item_set.emit(item)
	
	
	func set_parent(node: Node) -> void:
		parent = node
		
	
	func get_item() -> Node:
		return item
	
	
	func get_parent() -> Node:
		return parent
	
	
	func clear_item() -> void:
		_remove_from_scene(item)
		
		var removed_item: Node = item
		item = null
		
		item_removed.emit(removed_item)
	
	
	func is_empty() -> bool:
		return item == null
	
	
	func _add_to_scene(node: Node) -> void:
		if is_instance_valid(parent) and !node.is_inside_tree():
			parent.add_child(node)

	
	func _remove_from_scene(node: Node) -> void:
		if is_instance_valid(parent) and parent.is_ancestor_of(node):
			parent.remove_child(node)


class Iterator extends RefCounted:
	const DEFAULT_START: int = 0
	const DEFAULT_END: int = -1
	const DEFAULT_STEP: int = 1
	
	var bag: Bag
	var position: int
	var start: int
	var end: int
	var step: int
	
	
	func _init(
			struct: Bag,
			from: int = DEFAULT_START,
			to: int = DEFAULT_END,
			increment: int = DEFAULT_STEP) -> void:
		bag = struct
		step = increment
		start = from
		end = to if to > DEFAULT_END else bag.size()
	
	
	func has_next() -> bool:
		return position < end
	
	
	func _iter_init(_arg: Variant) -> bool:
		position = start
		return has_next()
	
	
	func _iter_next(_arg: Variant) -> bool:
		position += step
		return has_next()
	
	
	func _iter_get(_arg: Variant) -> Node:
		return bag.get_item(position)


signal item_set(item: Node, position: int)
signal item_removed(item: Node, position: int)

@export_group("Bag Data")
@export var data: BagData

var slots: Array[Slot]


func _ready() -> void:
	_ready_slots()


func put_item(position: int, item: Node) -> void:
	var slot: Slot = slots[position]
	slot.set_item(item)


func get_slot(position: int) -> Slot:
	return slots[position]


func get_item(position: int) -> Node:
	var slot: Slot = slots[position]
	return slot.get_item()


func get_item_list() -> Array:
	var items := []
	for slot in slots:
		items.append(slot.get_item())
	
	return items


func slot_is_empty(position: int) -> bool:
	var slot: Slot = slots[position]
	return slot.is_empty()


func size() -> int:
	return slots.size()


func resize(new_size: int, fill_slots: bool = true) -> void:
	var previous_size: int = slots.size()
	if new_size < previous_size:
		for position in range(new_size, previous_size):
			_delete_slot(position)
		slots.resize(new_size)
	elif new_size > previous_size:
		slots.resize(new_size)
		if fill_slots:
			for position in range(previous_size, new_size):
				var slot := _create_slot()
				_connect_slot(slot, position)
				_put_slot(position, slot)


func remove_item_at(position: int) -> void:
	var slot: Slot = slots[position]
	if !slot.is_empty():
		slot.clear_item()


func remove_slot(position: int) -> void:
	_delete_slot(position)
	slots.remove_at(position)


func create_iterator() -> Iterator:
	return Iterator.new(self)


func free() -> void:
	_delete_slots()
	super()


func _create_slot() -> Slot:
	return Slot.new()


func _add_slot(slot: Slot) -> void:
	slots.append(slot)


func _put_slot(position: int, slot: Slot) -> void:
	slots[position] = slot


func _delete_slot(position: int) -> void:
	var slot: Slot = slots[position]
	slot.free()


func _delete_slots() -> void:
	for slot in slots:
		if is_instance_valid(slot):
			slot.free()


func _ready_slots() -> void:
	if is_instance_valid(data):
		for slot_data in data.slots:
			var slot: Slot = _create_slot()
			_ready_slot(slot, slot_data)
			_add_slot(slot)
	
	_connect_slots()


func _ready_slot(slot: Slot, slot_data: Dictionary) -> void:
	for key in slot_data:
		var value: Variant = slot_data[key]
		match key:
			BagData.SLOT_KEY:
				if value is NodePath and !value.is_empty():
					var parent: Node = get_node(value)
					slot.set_parent(parent)
			BagData.ITEM_KEY:
				if value is NodePath and !value.is_empty():
					var item: Node = get_node(value)
					slot.set_item(item)


func _connect_slots() -> void:
	for position in slots.size():
		var slot: Slot = slots[position]
		_connect_slot(slot, position)


func _connect_slot(slot: Slot, position: int) -> void:
	var item_set_method: Callable = _on_slot_item_set.bind(position)
	if !slot.item_set.is_connected(item_set_method):
		var _err := slot.item_set.connect(item_set_method)
	
	var item_removed_method: Callable = _on_slot_item_removed.bind(position)
	if !slot.item_removed.is_connected(item_removed_method):
		var _err := slot.item_removed.connect(item_removed_method)


func _on_slot_item_set(item: Node, position: int) -> void:
	item_set.emit(item, position)


func _on_slot_item_removed(item: Node, position: int) -> void:
	item_removed.emit(item, position)

