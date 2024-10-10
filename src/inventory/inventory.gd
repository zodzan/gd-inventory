class_name Inventory
extends Node


var _inventory: Dictionary


func _ready() -> void:
	_ready_bags()


func get_bag(bag_id: StringName) -> LootBag:
	return _inventory.get(bag_id) as LootBag


func get_item(bag_id: StringName, position: int) -> LootItem:
	var bag: LootBag = get_bag(bag_id)
	var item: LootItem = null
	if is_instance_valid(bag) and position < bag.get_size():
		item = bag.get_item(position)
	
	return item


func get_item_list(bag_id: StringName) -> Array:
	var bag: LootBag = get_bag(bag_id)
	var item_list: Array = []
	if is_instance_valid(bag):
		item_list = bag.get_item_list()
	
	return item_list


func get_bag_size(bag_id: StringName) -> int:
	var bag: LootBag = get_bag(bag_id)
	var size: int = 0
	if is_instance_valid(bag):
		size = bag.get_size()
	
	return size


func add_bag(bag_id: StringName, bag: LootBag) -> void:
	var current_bag: LootBag = get_bag(bag_id)
	var bag_added: bool = false
	
	if !is_instance_valid(current_bag):
		bag_added = _add_bag_to_scene(bag)
		if bag_added:
			_inventory[bag_id] = bag


func remove_bag(bag_id: StringName) -> void:
	var bag: LootBag = get_bag(bag_id)
	var bag_removed: bool = false
	
	if is_instance_valid(bag):
		bag_removed = _remove_bag_from_scene(bag)
		if bag_removed:
			_inventory[bag_id] = null


func put_item(bag_id: StringName, position: int, item: LootItem) -> void:
	var bag: LootBag = get_bag(bag_id)
	if is_instance_valid(bag) and position < bag.get_size():
		bag.put_item(position, item)


func remove_item_at(bag_id: StringName, position: int) -> void:
	var bag: LootBag = get_bag(bag_id)
	if is_instance_valid(bag) and position < bag.get_size():
		bag.remove_item_at(position)


func create_bag_iterator(bag_id: StringName) -> LootBag.Iterator:
	var iterator: LootBag.Iterator = null
	var bag: LootBag = get_bag(bag_id)
	if is_instance_valid(bag):
		iterator = bag.create_iterator()
	
	return iterator


func connect_bag_item_set_signal(bag_id: StringName, method: Callable
		) -> void:
	var bag: LootBag = get_bag(bag_id)
	if is_instance_valid(bag) and !bag.item_set.is_connected(method):
		var _err := bag.item_set.connect(method)


func connect_bag_item_removed_signal(bag_id: StringName, method: Callable
		) -> void:
	var bag: LootBag = get_bag(bag_id)
	if is_instance_valid(bag) and !bag.item_removed.is_connected(method):
		var _err := bag.item_removed.connect(method)


func _add_bag_to_scene(bag: LootBag) -> bool:
	var bag_enabled: bool = bag.is_inside_tree()
	var success: bool = false
	if !bag_enabled:
		add_child(bag)
		success = true
	
	return success


func _remove_bag_from_scene(bag: LootBag) -> bool:
	var bag_enabled: bool = bag.is_inside_tree() and is_ancestor_of(bag)
	var success: bool = false
	if bag_enabled:
		remove_child(bag)
		success = true
	
	return success


func _ready_bag(bag_id: StringName, bag_path: NodePath) -> void:
	var bag: LootBag = get_node_or_null(bag_path)
	if is_instance_valid(bag):
		add_bag(bag_id, bag)


func _ready_bags() -> void:
	pass
