class_name LootBag
extends Node


class Slot extends Object:
	signal item_set(item: LootItem)
	signal item_removed(item: LootItem)
	
	var item: LootItem : get = get_item, set = set_item
	
	
	func get_item() -> LootItem:
		return item
	
	
	func set_item(new_item: LootItem) -> void:
		if is_instance_valid(item):
			var current_item: LootItem = item
			item = null
			item_removed.emit(current_item)
		
		item = new_item
		item_set.emit(item)
	
	
	func clear_item() -> void:
		if is_instance_valid(item):
			var removed_item: LootItem = item
			item = null
			item_removed.emit(removed_item)
	
	
	func is_empty() -> bool:
		return item == null
	
	
	func free() -> void:
		if is_instance_valid(item):
			item.queue_free()
		super()


class Iterator extends RefCounted:
	const DEFAULT_START: int = 0
	const DEFAULT_END: int = -1
	const DEFAULT_STEP: int = 1
	
	var bag: LootBag
	var position: int
	var start: int
	var end: int
	var step: int
	
	
	func _init(
			loot_bag: LootBag,
			from: int = DEFAULT_START,
			to: int = DEFAULT_END,
			increment: int = DEFAULT_STEP) -> void:
		bag = loot_bag
		step = increment
		start = from
		end = to if to > DEFAULT_END else bag.get_size()
	
	
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


signal item_set(item: LootItem, position: int)
signal item_removed(item: LootItem, position: int)

@export var default_size: int = 0

var slots: Array[Slot]
 

func _ready() -> void:
	slots = []
	_ready_slots()


func put_item(position: int, item: LootItem) -> void:
	var slot: Slot = slots[position]
	slot.set_item(item)


func get_item(position: int) -> LootItem:
	var slot: Slot = slots[position]
	return slot.get_item()


func get_item_list() -> Array:
	var items := []
	for slot in slots:
		items.append(slot.get_item())
	
	return items


func size() -> int:
	return slots.size()


func slot_is_empty(position: int) -> bool:
	var slot: Slot = slots[position]
	return slot.is_empty()


func resize(new_size: int) -> void:
	var previous_size: int = slots.size()
	if new_size < previous_size:
		for position in range(new_size, previous_size):
			var slot: Slot = slots[position]
			slot.free()
		slots.resize(new_size)
	elif new_size > previous_size:
		slots.resize(new_size)
		for position in range(previous_size, new_size):
			var slot: Slot = Slot.new()
			_ready_slot(position, slot)
			slots[position] = slot
	

func remove_item_at(position: int) -> void:
	var slot: Slot = slots[position]
	slot.clear_item()


func create_iterator() -> Iterator:
	return Iterator.new(self)


func free() -> void:
	for slot in slots:
		slot.free()
	super()


func _ready_slot(position: int, slot: Slot) -> void:
	_connect_slot(position, slot)


func _ready_slots() -> void:
	for position in default_size:
		var slot: Slot = Slot.new()
		_ready_slot(position, slot)
		slots.append(slot)


func _ready_item(slot: Slot, item: LootItem) -> void:
	slot.set_item(item)


# Slots must be ready before this method is called. If a slot is invalid, this 
# method will fail.
func _ready_items() -> void:
	var item_list: Array = get_children()
	var slot: Slot = null
	for position in item_list.size():
		if position < slots.size():
			slot = slots[position]
		else:
			slot = Slot.new()
			_ready_slot(position, slot)
			slots.append(slot)
	
		var item: LootItem = item_list[position]
		if is_instance_valid(item):
			_ready_item(slot, item)


func _connect_slot(position: int, slot: Slot) -> void:
	var item_set_method: Callable = _on_slot_item_set.bind(position)
	if !slot.item_set.is_connected(item_set_method):
		var _err := slot.item_set.connect(item_set_method)
	
	var item_removed_method: Callable = _on_slot_item_removed.bind(position)
	if !slot.item_removed.is_connected(item_removed_method):
		var _err := slot.item_removed.connect(item_removed_method)


func _on_slot_item_set(item: LootItem, position: int) -> void:
	item_set.emit(item, position)


func _on_slot_item_removed(item: LootItem, position: int) -> void:
	item_removed.emit(item, position)
