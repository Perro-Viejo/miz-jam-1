class_name Player
extends "res://src/Characters/Actor.gd"

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
export(float) var camera_shake_time
export(bool) var can_shake_camera = true

var motion = Vector2.ZERO
var velocity = Vector2.ZERO
var _is_camera_shaking := false
var _camera_shake_amount := 15.0
var _shake_timer := 0.0

var is_control_active = true

func _ready() -> void:
	speak("¡Juimonos!")
	Event.connect('set_control_active', self, '_set_control_active')
	Event.connect('player_killed', self, '_explode')
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
	if _is_camera_shaking:
		_shake_timer -= delta
		$Camera2D.offset = Vector2(
			rand_range(-1.0, 1.0) * _camera_shake_amount,
			rand_range(-1.0, 1.0) * _camera_shake_amount
		)

		if _shake_timer <= 0.0:
			_is_camera_shaking = false
			$Camera2D.offset = Vector2.ZERO

func play_animation(state: String = '') -> void:
	match state:
		_:
			sprite.play('Idle')

func shake_camera() -> void:
	if not can_shake_camera: return
	_shake_timer = camera_shake_time
	_is_camera_shaking = true

func play_fs(id):
	Event.emit_signal('play_requested', "Player", id)

func _set_control_active(is_active: bool):
	is_control_active = is_active
	
func speak(text := '', time_to_disappear := 0):
	Event.emit_signal('character_spoke', self, text, time_to_disappear)


func _should_speak(character_name, text, time, emotion) -> void:
	if name.to_lower() == character_name:
		speak(text, time)
		Event.emit_signal('dx_requested' , character_name, emotion)


func _toggle_control() -> void:
	$StateMachine.transition_to(STATES.IDLE)

func _explode() -> void:
	if immortal: return
	
	shake_camera()
	Event.emit_signal("play_requested", "Boat", "Explode")
	Event.emit_signal("stop_requested", "Boat", "Loop")
	play_splatter(false)
	$AnimatedSprite.play(
		'Explode0%d' % (randi() % 3 + 1)
	)
	is_control_active = false
	motion = Vector2.ZERO
	yield($AnimatedSprite, 'animation_finished')
	$AnimatedSprite/WaterSplatter.hide()
	Event.emit_signal('level_lost')

func get_class():
	return "Player"

func play_splatter(play := true) -> void:
	if play:
		$AnimatedSprite/WaterSplatter.show()
		$AnimatedSprite/WaterSplatter.play('Splash')
	else:
		$AnimatedSprite/WaterSplatter.hide()
		$AnimatedSprite/WaterSplatter.playing = false
