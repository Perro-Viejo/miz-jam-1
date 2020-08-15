class_name Player
extends KinematicBody2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(Color) var dialog_color

const STATES = {
	WALK = 'Walk',
	IDLE = 'Idle',
	GRAB = 'Grab',
	DROP = 'Drop',
	FISH = 'Fish',
	TALK = 'Talk'
}

var is_moving = false
var is_out: bool = false
var node_to_interact: Pickable = null setget _set_node_to_interact
var grabbing: bool = false
var on_ground: bool = false
var fishing: bool = false
var fs_id: String = 'FS_Dirt'
var foot = 'L'
var is_paused := false

onready var cam: Camera2D = $Camera2D
onready var sprite: AnimatedSprite = $AnimatedSprite
onready var fishing_spot: ColorRect = $FishingSpot
onready var foot_area: Area2D = $FootArea
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	
	fishing_spot._fish_splash = $FishSplash
	
	# Escuchar eventos de los hijos de satán
	$FootArea.connect('body_entered', self, 'toggle_on_ground', [ true ])
	$FootArea.connect('body_exited', self, 'toggle_on_ground')
	$AnimatedSprite.connect('frame_changed', self, '_on_frame_changed')

	# Conectarse a eventos del universo
	Event.connect('line_triggered', self, '_should_speak')
	Event.connect('control_toggled', self, '_toggle_control')

	# Definir estado por defecto
	play_animation()


func change_zoom(out: bool = true) -> void:
	is_out = out

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


func play_animation(state: String = '') -> void:
	match state:
		_:
			sprite.play('Idle')


func toggle_on_ground(body: Node2D, on: = false) -> void:
	if not body.is_in_group('Floor'): return


func _on_frame_changed() -> void:
	if $AnimatedSprite.animation == 'Run' \
		or $AnimatedSprite.animation == 'RunGrab':
		match $AnimatedSprite.frame:
			0,2:
				play_fs(fs_id)
				if fs_id == 'FS_Water':
					match foot:
						'L':
							$Splash_L.set_emitting(true)
							$Splash_R.restart()
							foot = 'R'
						'R':
							$Splash_R.set_emitting(true)
							$Splash_L.restart()
							foot = 'L'


func play_fs(id):
	Event.emit_signal('play_requested', "Player", id)


func speak(text := '', time_to_disappear := 0):
	Event.emit_signal('character_spoke', self, text, time_to_disappear)


# Sirve para disparar comportamientos cuando se ha completado un diálogo
#func spoke():
#	pass


func _should_speak(character_name, text, time, emotion) -> void:
	if name.to_lower() == character_name:
		speak(text, time)
		Event.emit_signal('dx_requested' , character_name, emotion)


func _toggle_control() -> void:
	$StateMachine.transition_to(STATES.IDLE)
	is_paused = !is_paused


func _set_node_to_interact(new_node: Pickable) -> void:
	if node_to_interact:
		node_to_interact.hide_interaction()
	if new_node and new_node.is_in_group('Pickable'):
		new_node.show_interaction()

	node_to_interact = new_node
