class_name Inventory
extends Node


var _inventory: Dictionary


func _ready() -> void:
	_ready_bags()


func put_item(bag_id: StringName, position: int, item: Node) -> void:
	var bag: Bag = get_bag(bag_id)
	if is_instance_valid(bag):
		bag.put_item(position, item)


func remove_item_at(bag_id: StringName, position: int) -> void:
	var bag: Bag = get_bag(bag_id)
	if is_instance_valid(bag):
		bag.remove_item_at(position)


func get_bag(bag_id: StringName) -> Bag:
	return _inventory.get(bag_id) as Bag


func get_item(bag_id: StringName, position: int) -> Node:
	var bag: Bag = get_bag(bag_id)
	var item: Node = null
	if is_instance_valid(bag):
		item = bag.get_item(position)
	
	return item


func get_item_list(bag_id: StringName) -> Array:
	var bag: Bag = get_bag(bag_id)
	var item_list: Array = []
	if is_instance_valid(bag):
		item_list = bag.get_item_list()
	
	return item_list


func get_bag_size(bag_id: StringName) -> int:
	var bag: Bag = get_bag(bag_id)
	var size: int = 0
	if is_instance_valid(bag):
		size = bag.size()
	
	return size


func create_bag_iterator(bag_id: StringName) -> Bag.Iterator:
	var iterator: Bag.Iterator = null
	var bag: Bag = get_bag(bag_id)
	if is_instance_valid(bag):
		iterator = bag.create_iterator()
	
	return iterator


func connect_bag_item_set_signal(bag_id: StringName, method: Callable
		) -> void:
	var bag: Bag = get_bag(bag_id)
	if is_instance_valid(bag) and !bag.item_set.is_connected(method):
		var _err := bag.item_set.connect(method)


func connect_bag_item_removed_signal(bag_id: StringName, method: Callable
		) -> void:
	var bag: Bag = get_bag(bag_id)
	if is_instance_valid(bag) and !bag.item_removed.is_connected(method):
		var _err := bag.item_removed.connect(method)


func _add_bag(bag_id: StringName, bag: Bag) -> void:
	if !_inventory.has(bag_id):
		_add_to_scene(bag)
		_inventory[bag_id] = bag


func _remove_bag(bag_id: StringName) -> void:
	var bag: Bag = get_bag(bag_id)
	if is_instance_valid(bag):
		_remove_from_scene(bag)
		_inventory[bag_id] = null


func _add_to_scene(bag: Bag) -> void:
	if !bag.is_inside_tree():
		add_child(bag)


func _remove_from_scene(bag: Bag) -> void:
	if bag.is_inside_tree() and is_ancestor_of(bag):
		remove_child(bag)


func _ready_bag(bag_id: StringName, bag_path: NodePath) -> void:
	var bag: Bag = get_node_or_null(bag_path)
	if is_instance_valid(bag):
		_add_bag(bag_id, bag)


func _ready_bags() -> void:
	pass

