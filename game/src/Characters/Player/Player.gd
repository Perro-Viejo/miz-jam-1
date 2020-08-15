class_name Player
extends KinematicBody2D

const STATES = {
	MOVE = 'Move',
	IDLE = 'Idle',
	DEAD = 'Dead'
}

onready var cam: Camera2D = $Camera2D
onready var sprite: AnimatedSprite = $AnimatedSprite

export(float) var speed = 30
export(float) var acceleration = 0.05
export(float) var deceleration = 0.01
var motion = Vector2.ZERO
var velocity = Vector2.ZERO

func _ready() -> void:
	play_animation()

func change_zoom(out: bool = true) -> void:
	if out:
		Event.emit_signal('play_requested', 'UI', 'ZoomOut')
	else:
		Event.emit_signal('play_requested', 'UI', 'ZoomIn')

	$Tween.remove_all()
	$Tween.interpolate_property(
		cam,
		'zoom',
		cam.zoom,
		Vector2.ONE * 2 if out else Vector2.ONE / 2,
		1.0 if out else 0.5,
		Tween.TRANS_QUINT,
		Tween.EASE_OUT
	)
	$Tween.start()

	yield($Tween, 'tween_completed')
	
func _physics_process(delta):
	motion = move_and_slide(motion)

func play_animation(state: String = '') -> void:
	match state:
		_:
			sprite.play('Idle')


func play_fs(id):
	Event.emit_signal('play_requested', "Player", id)


func speak(text := '', time_to_disappear := 0):
	Event.emit_signal('character_spoke', self, text, time_to_disappear)


func _should_speak(character_name, text, time, emotion) -> void:
	if name.to_lower() == character_name:
		speak(text, time)
		Event.emit_signal('dx_requested' , character_name, emotion)


func _toggle_control() -> void:
	$StateMachine.transition_to(STATES.IDLE)