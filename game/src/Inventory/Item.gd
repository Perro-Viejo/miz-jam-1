extends Node
class_name Item

const ITEM_TYPE = "Item"

export(int) var size = 0
export(String) var item_name = "key"
#Averiguar sobre grupos y esos visajes
export(String) var category = "default"

export(String) var description = ""

var container: Node = null
var sprite: Sprite = null

func is_type(type):
	return type == self.ITEM_TYPE or .is_type(type)

func get_type():
	return self.ITEM_TYPE

func activate() -> void:
	pass

func desactivate() -> void:
	pass

func _ready():
	item_name = get_parent().selected_item
	var _sprite = Sprite.new()
	_sprite.texture = load("res://assets/images/world/%s.png" % item_name)
	add_child(_sprite)
	var position = owner.get_node("TreasurePosition")
	_sprite.global_position = position.global_position
