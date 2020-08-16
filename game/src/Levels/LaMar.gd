extends Node2D

onready var _player = $Player
onready var _start_area = $StartArea

func _ready():
	_player.global_position = _start_area.get_node("./PlayerStartPosition").global_position

func on_win():
	print("Won level")
	pass
