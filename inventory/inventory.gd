class_name Inventory
extends Node


var _inventory: Dictionary


func _ready() -> void:
	_ready_bags()


func put_item(bag_id: String, position: int, item: Node) -> void:
	var bag: Bag = get_bag(bag_id)
	bag.put_item(position, item)


func remove_item_at(bag_id: String, position: int) -> void:
	var bag: Bag = get_bag(bag_id)
	bag.remove_item_at(position)


func get_bag(bag_id: String) -> Bag:
	return _inventory.get(bag_id) as Bag


func get_item(bag_id: String, position: int) -> Node:
	var bag: Bag = get_bag(bag_id)
	
	return bag.get_item(position)


func get_item_list(bag_id: String) -> Array:
	var bag: Bag = get_bag(bag_id)
	
	return bag.get_item_list()


func get_bag_size(bag_id: String) -> int:
	var bag: Bag = get_bag(bag_id)
	
	return bag.size()


func connect_bag_item_set_signal(bag_id: String, method: Callable
		) -> void:
	var bag: Bag = get_bag(bag_id)
	if !bag.item_set.is_connected(method):
		var _err := bag.item_set.connect(method)


func connect_bag_item_removed_signal(bag_id: String, method: Callable
		) -> void:
	var bag: Bag = get_bag(bag_id)
	if !bag.item_removed.is_connected(method):
		var _err := bag.item_removed.connect(method)


func create_bag_iterator(bag_id: String) -> Bag.Iterator:
	var bag: Bag = get_bag(bag_id)
	
	return bag.create_iterator()


func _add_bag(bag_id: String, bag: Bag) -> void:
	if !_inventory.has(bag_id):
		_add_to_scene(bag)
		_inventory[bag_id] = bag


func _remove_bag(bag_id: String) -> void:
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


func _ready_bag(bag_id: String, bag_path: NodePath) -> void:
	var bag: Bag = get_node_or_null(bag_path)
	if is_instance_valid(bag):
		_add_bag(bag_id, bag)


func _ready_bags() -> void:
	pass

