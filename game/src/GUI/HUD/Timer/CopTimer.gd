extends Node2D
class_name CopTimer

export(float) var timer_seconds = 10
onready var _tween: Tween = $Cop.get_node("Tween")

func _ready():
	$Cop.global_position = $StartPoint.global_position
	$Cop.get_node("AnimatedSprite").play("default")
	
	# Conectarse a eventos de los hijos
	if not _tween.is_connected("tween_completed", self, "timeout"):
		_tween.connect("tween_completed", self, "timeout")
	
	# Conectarse a eventos del universo chimpokomón
	if not Event.is_connected('player_killed', self, '_stop'):
		Event.connect('player_killed', self, '_stop')
		Event.connect('level_ended', self, '_stop')

func start():
	timer_seconds = Data.get_data(Data.LEVEL_TIME)
	_tween.interpolate_property(
		$Cop, 
		"global_position:x", 
		$StartPoint.global_position.x, 
		$EndPoint.global_position.x, 
		timer_seconds)
	_ready()
	Event.emit_signal("play_requested", "UI", "Car_Start")
	yield(get_tree().create_timer(.7), 'timeout')
	Event.emit_signal("play_requested", "UI", "Car_Loop")
	_tween.start()
	


func timeout(obj, key):
	Event.emit_signal("play_requested", "UI", "Kill_Alert")
	Event.emit_signal("stop_requested", "UI", "Car_Loop")
	Event.emit_signal("target_deployed", $EndPoint)


func _stop() -> void:
	_tween.remove_all()

