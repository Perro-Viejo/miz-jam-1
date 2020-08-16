extends Node2D

onready var _player = $Player
onready var _start_area = $StartArea

func _ready():
	_player.global_position = _start_area.get_node("./PlayerStartPosition").global_position
	
	# Conectarse a eventos del mundo chimpocomón
	Event.connect('level_lost', self, '_on_lose')

func on_win():
	print("Won level")
	
func _on_lose():
	Event.emit_signal("Restart")
