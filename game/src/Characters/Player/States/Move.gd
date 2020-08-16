extends "res://src/StateMachine/State.gd"
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export var rotate_speed = 1

var moving = false

func _ready():
	Event.connect('dialog_event', self, '_on_dialog_event')

func _physics_process(delta) -> void:
	if owner.is_control_active:
		if Input.is_action_pressed("Right"):
			owner.rotation += rotate_speed*delta
				
		if Input.is_action_pressed("Left"):
			owner.rotation -= rotate_speed*delta
		
		owner.velocity = Vector2(owner.speed, 0).rotated(owner.rotation - PI/2)
		if Input.is_action_pressed("Up"):
			owner.motion = owner.motion.linear_interpolate(owner.velocity, owner.acceleration)
			owner.play_splatter()
			if not moving:
				moving = true
				Event.emit_signal("play_requested", "Boat", "Start")
				Event.emit_signal("play_requested", "Boat", "Loop")
		else:
			owner.motion = owner.motion.linear_interpolate(Vector2.ZERO, owner.deceleration)
			owner.play_splatter(false)
			if moving:
				moving = false
				Event.emit_signal("play_requested", "Boat", "Stop")
				Event.emit_signal("stop_requested", "Boat", "Loop")
	
func enter(msg: Dictionary = {}) -> void:
	.enter(msg)

func exit() -> void:
	.exit()
