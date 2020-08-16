extends "res://src/StateMachine/State.gd"
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export var rotate_speed = 1

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
		else:
			owner.motion = owner.motion.linear_interpolate(Vector2.ZERO, owner.deceleration)
	
func enter(msg: Dictionary = {}) -> void:
	.enter(msg)

func exit() -> void:
	.exit()
