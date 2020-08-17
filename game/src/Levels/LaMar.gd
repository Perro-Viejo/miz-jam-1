extends Node2D

onready var _player = $Player
onready var _start_area = $StartArea

export (int)var initial_angle = PI/4
export (String, FILE, '*.tscn') var next_level: String

func _ready():
	_player.global_position = _start_area.get_node("./PlayerStartPosition").global_position
	_player.rotation = initial_angle
	# Conectarse a eventos del mundo chimpocomón
	Event.connect('level_lost', self, '_on_lose')
	Event.emit_signal("play_requested", "MX", "inGame")

func on_win():
	_player.play_splatter(false)
	Event.emit_signal("stop_requested", "Boat", "Loop")
	Event.emit_signal("play_requested", "UI", "Win")
	Event.emit_signal("stop_requested", "MX", "inGame")
	Event.emit_signal('set_control_active', false)
	
	yield(get_tree().create_timer(2), 'timeout')
	if next_level:
		Event.emit_signal('ChangeScene', next_level)
	else:
		Event.emit_signal("ChangeScene", Data.get_data(Data.MAIN_MENU_SCN))

func _on_lose():
	Event.emit_signal("Restart")
