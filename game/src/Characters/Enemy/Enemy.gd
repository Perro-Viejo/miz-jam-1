tool
class_name Enemy
extends Node2D

enum LookingDirection { UP, RIGHT, DOWN, LEFT }
enum LookingPattern { NONE, RIGHT_LEFT, UP_DOWN, CLOCKWISE }

export var default_pattern: PackedScene
export var sprite: Texture
export var time_to_catch := 3 # En segundos
export var time_to_change := 6
export(LookingDirection) var looking_direction = LookingDirection.RIGHT
export(LookingPattern) var looking_pattern = LookingPattern.NONE
export var inverse_looking_pattern := false

var alert_count := 0

var _dflt_pattern: VisibilityPattern = null
var _is_alert := false
var _player_node: Player = null
var _is_killing := false
var _dflt_alert_animation := 'Show'
var _looking_at := -1
var _prev_alert_count := -1

onready var _anchors: Dictionary = {
	n = $Anchors/North,
	e = $Anchors/East,
	s = $Anchors/South,
	w = $Anchors/West
}

func _ready():
	self.z_index = 3
	
	$Alert.self_modulate.a = 0
	$Timer.wait_time = time_to_change
	
	# Conectarse a señales de los hijos
	$Tween.connect('tween_completed', self, '_on_tween_completed')
	$Timer.connect('timeout', self, '_change_looking_direction')

	if sprite:
		$Sprite.texture = sprite

	if default_pattern:
		_dflt_pattern = default_pattern.instance()
		$Patterns.add_child(_dflt_pattern)
	else:
		_dflt_pattern = $Patterns.get_child(0) as VisibilityPattern
	_dflt_pattern.connect('player_entered', self, '_show_alert')
	_dflt_pattern.connect('player_left', self, '_hide_alert')

	# Establecer posición inicial
	match looking_direction:
		LookingDirection.RIGHT:
			_dflt_pattern.position = _anchors.e.position
		LookingDirection.LEFT:
			_dflt_pattern.position = _anchors.w.position
			$Sprite.flip_h = !$Sprite.flip_h
			_dflt_pattern.scale.x *= -1
		LookingDirection.UP:
			_dflt_pattern.position = _anchors.n.position
			_dflt_pattern.rotation_degrees = -90
		LookingDirection.DOWN:
			_dflt_pattern.position = _anchors.s.position
			_dflt_pattern.rotation_degrees = 90
	_looking_at = looking_direction

	# Iniciar el temporizador que hará que el enemigo mire pa' otro lado
	$Timer.start()

func _on_tween_completed(obj: Object, key: NodePath):
	var subname := key.get_subname(0)

	match subname:
		'_destroy_player':
			return
		'alert_count':
			_destroy_player()
			return
		'global_position':
			Event.emit_signal('player_killed')
			return
		'self_modulate':
			if not _is_alert:
				$Alert.stop()
				$Alert.animation = _dflt_alert_animation
				$Timer.start()
				return
	if _is_killing: return

	$Tween.interpolate_property(
		self, 'alert_count',
		time_to_catch, 0,
		time_to_catch, Tween.TRANS_LINEAR, Tween.EASE_IN, 1
	)
	if not $Tween.is_connected('tween_step', self, '_on_tween_step'):
		$Tween.connect('tween_step', self, '_on_tween_step')

# Que cuando se active zona de enemigo muestre un emoticono
func _show_alert(player_node: Node) -> void:
	Event.emit_signal("play_requested", "UI", "Alert_Gen")
	if not _player_node: _player_node = player_node
	$Timer.stop()
	_is_alert = true
	$Alert.play(_dflt_alert_animation)
	$Tween.interpolate_property(
		$Alert, 'self_modulate:a',
		0.0, 1.0,
		0.15, Tween.TRANS_EXPO, Tween.EASE_IN
	)
	$Tween.start()

func _hide_alert() -> void:
	_set_defaults()
	$Tween.remove_all()
	$Tween.interpolate_property(
		$Alert, 'self_modulate:a',
		1.0, 0.0,
		0.1, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	$Tween.start()

func _destroy_player() -> void:
	Event.emit_signal("play_requested", "Enemy", "Attk_Gen")
	if not $Tween.is_connected('tween_step', self, '_on_tween_step'):
		$Tween.disconnect('tween_step', self, '_on_tween_step')
	if _is_alert:
		_is_killing = true

		# Si el jugador no ha dejado las zonas de visión, matar al hijueputa
		$Tween.interpolate_property(
			$Sprite, 'global_position',
			global_position, _player_node.global_position,
			0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN
		)
		$Tween.interpolate_property(
			$Alert, 'self_modulate:a',
			1.0, 0.0,
			0.3, Tween.TRANS_SINE, Tween.EASE_OUT
		)
		$Tween.interpolate_property(
			$Patterns, 'modulate:a',
			1.0, 0.0,
			0.1, Tween.TRANS_SINE, Tween.EASE_OUT
		)
		$Tween.start()

func _on_tween_step(
		obj: Object, key: NodePath, elapsed: float, value: Object
	) -> void:
		if _prev_alert_count != alert_count:
			_prev_alert_count = alert_count
			Event.emit_signal('play_requested', 'UI', 'Number')
		$Alert.play(str(alert_count + 1))
		

func _set_defaults() -> void:
	_player_node = null
	_is_alert = false
	alert_count = 0
	_prev_alert_count = -1
	if $Tween.is_connected('tween_step', self, '_on_tween_step'):
		$Tween.disconnect('tween_step', self, '_on_tween_step')

func _change_looking_direction() -> void:
	match looking_pattern:
		LookingPattern.RIGHT_LEFT:
			$Sprite.flip_h = !$Sprite.flip_h
			if $Sprite.flip_h:
				_dflt_pattern.position = _anchors.w.position
			else:
				_dflt_pattern.position = _anchors.e.position
			_dflt_pattern.scale.x *= -1
		LookingPattern.UP_DOWN:
			if _dflt_pattern.rotation_degrees < 0:
				_dflt_pattern.rotation_degrees = 90
				_dflt_pattern.position = _anchors.s.position
			else:
				_dflt_pattern.rotation_degrees = -90
				_dflt_pattern.position = _anchors.n.position
			_dflt_pattern.scale.y *= -1
		LookingPattern.CLOCKWISE:
			match _looking_at:
				LookingDirection.UP:
					_dflt_pattern.position = _anchors.e.position
					_dflt_pattern.rotation_degrees = 0
					$Sprite.flip_h = false
					_dflt_pattern.scale.y = 1
					_looking_at = LookingDirection.RIGHT
				LookingDirection.RIGHT:
					_dflt_pattern.rotation_degrees = 90
					_dflt_pattern.position = _anchors.s.position
					_dflt_pattern.scale.y = -1
					_looking_at = LookingDirection.DOWN
				LookingDirection.DOWN:
					$Sprite.flip_h = true
					_dflt_pattern.position = _anchors.w.position
					_dflt_pattern.scale.x = -1
					_dflt_pattern.scale.y = 1
					_dflt_pattern.rotation_degrees = 0
					_looking_at = LookingDirection.LEFT
				LookingDirection.LEFT:
					_dflt_pattern.rotation_degrees = -90
					_dflt_pattern.position = _anchors.n.position
					_dflt_pattern.scale.x = 1
					_dflt_pattern.scale.y = 1
					_looking_at = LookingDirection.UP
	# Reiniciar el temporizador para volver a cambiar la mirada al futuro
	$Timer.start()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
# ▒ N O T A S ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
# El bicho puede tener un looking direction que indica cuál de los patrones está
# activo y lo hace visible.

# Debería haber algo que permita decir si el patrón se debe girar para ponerse
# en uno de los puntos de ancla.

# Para los puntos de ancla podría no ser necesario tener Point2D, sino calcular
# todo por programación. Aunque hay algo bueno de tenerlos separados del cálculo
# y es que el sprite podría moverse o ser modificado sin que se afecten los puntos.

# (!) Debe haber algo que indique cómo es el comportamiento del enemigo, si se
# gira y cada cuanto, si se mueve.

# Al enemigo debería poder configurarse el Sprite y el patrón para cada una de
# las direcciones de visión. Si no se define un patrón para cierta dirección,
# podría usarse el que se define por defecto pero girado X grados.
# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ N O T A S ▒
# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
