extends Node2D

onready var _player = $Player
onready var _start_area = $StartArea

export (String, FILE, '*.tscn') var next_level: String
export var initial_angle := 0
export var level_time := 10

func _ready():
	_player.global_position = _start_area.get_node("./PlayerStartPosition").global_position
	_player.rotation_degrees = initial_angle
	
	Data.set_data(Data.LEVEL_TIME, level_time)
	Data.set_data(Data.LEVEL_FINISHED, false)

	# Conectarse a eventos del mundo chimpocomón
	Event.connect('level_lost', self, '_on_lose')
	Event.emit_signal("world_entered")

func on_win():
	_player.play_splatter(false)

	Data.set_data(Data.LEVEL_FINISHED, true)
	Event.emit_signal('level_ended')
	Event.emit_signal("stop_requested", "Boat", "Loop")
	Event.emit_signal("play_requested", "UI", "Win")

	yield(get_tree().create_timer(2), 'timeout')
	if next_level:
		Event.emit_signal('ChangeScene', next_level)
	else:
		Event.emit_signal('set_control_active', false)
		$Player/Camera2D.current = false
		$JumpingBoat/Camera2D.current = true
		$AnimationPlayer.play('Appear')
		yield($AnimationPlayer, 'animation_finished')
		$AnimationPlayer.play('GoParty')
		yield($AnimationPlayer, 'animation_finished')
		Event.emit_signal("play_requested", "MX", "Win")
		Event.emit_signal("stop_requested", "MX", "inGame")
		Event.emit_signal('game_ended')

func _on_lose():
	Event.emit_signal("stop_requested", "UI", "Scope")
	Event.emit_signal("stop_requested", "UI", "Car_Loop")
	Event.emit_signal("stop_requested", "UI", "Car_Siren")
	Event.emit_signal("Restart")
