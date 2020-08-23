extends "res://src/StateMachine/State.gd"
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export var rotate_speed = 1

var moving = false
var dash_timer = 0.5
var dash_pressed = 0
var dashing_time = 0.5
var is_dashing = false
var current_time = dash_timer

func _ready():
	Event.connect('dialog_event', self, '_on_dialog_event')

func _unhandled_input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if not Event.Paused:
		if event is InputEventKey:
			if event.pressed and event.scancode == KEY_UP and just_pressed:
				dash_pressed += 1
				
				if !is_dashing && dash_pressed >= 2:
					is_dashing = true
					owner.motion = Vector2(owner.speed*2, 0).rotated(owner.rotation - PI/2)
					owner.play_splatter()
					moving = true
					Event.emit_signal("play_requested", "Boat", "Start")

func _physics_process(delta) -> void:
	if dash_timer < 0:
		dash_timer = 0
		dash_pressed = 0
		dashing_time = 0.5
		is_dashing = false
		
	current_time -= delta
			
	if owner.is_control_active:
		if Input.is_action_pressed("Right"):
			owner.rotation += rotate_speed*delta
				
		if Input.is_action_pressed("Left"):
			owner.rotation -= rotate_speed*delta
		
		owner.velocity = Vector2(owner.speed, 0).rotated(owner.rotation - PI/2)
		
		if is_dashing:
			dashing_time -= delta
			
			if dashing_time < 0:
				dashing_time = 1
				is_dashing = false
				dash_timer = 0
				dash_pressed = 0
				owner.motion = owner.motion.linear_interpolate(Vector2.ZERO, owner.acceleration)
				
		elif Input.is_action_pressed("Up"):	
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
