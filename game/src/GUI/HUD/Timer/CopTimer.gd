extends Node2D
class_name CopTimer

export(float) var timer_seconds = 10
onready var _tween = $Cop.get_node("Tween")

func _ready():
	$Cop.global_position = $StartPoint.global_position
	$Cop.get_node("AnimatedSprite").play("default")
	
func start():
	timer_seconds = Data.get_data(Data.LEVEL_TIME)
	_tween.connect("tween_completed", self, "timeout")
	_tween.interpolate_property(
		$Cop, 
		"global_position:x", 
		$StartPoint.global_position.x, 
		$EndPoint.global_position.x, 
		timer_seconds)
	_tween.start()
	_ready()
	
func timeout(obj, key):
	Event.emit_signal("target_deployed", $EndPoint)
