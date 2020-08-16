extends Node2D

onready var _player = $Player
onready var _start_area = $StartArea

export (int)var initial_angle = PI/4

func _ready():
	_player.global_position = _start_area.get_node("./PlayerStartPosition").global_position
	_player.rotation = initial_angle
	# Conectarse a eventos del mundo chimpocomón
	Event.connect('level_lost', self, '_on_lose')
	Event.emit_signal("play_requested", "MX", "inGame")

func on_win():
	Event.emit_signal("play_requested", "UI", "Win")
	Event.emit_signal("stop_requested", "MX", "inGame")
	Event.emit_signal('set_control_active', false)
	
func _on_lose():
	Event.emit_signal("Restart")
