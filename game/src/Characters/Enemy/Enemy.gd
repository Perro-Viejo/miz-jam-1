tool
class_name Enemy
extends Node2D

export(PackedScene) var default_pattern
export(Texture) var sprite
export(int) var time_to_catch = 3 # En segundos

var alert_count := 0

var _dflt_pattern: VisibilityPattern = null
var _is_alert := false
var _player_node: Player = null
var _is_killing := false

onready var _anchors: Dictionary = {
	n = $Anchors/North,
	e = $Anchors/East,
	s = $Anchors/South,
	w = $Anchors/West
}

func _ready():
	self.z_index = 3
	
	$Alert.self_modulate.a = 0
	
	# Conectarse a señales de los hijos
	$Tween.connect('tween_completed', self, '_on_tween_completed')
	
	if sprite:
		$Sprite.texture = sprite
	if default_pattern:
		_dflt_pattern = default_pattern.instance()
		_dflt_pattern.position = _anchors.e.position
		_dflt_pattern.connect('player_entered', self, '_show_alert')
		_dflt_pattern.connect('player_left', self, '_hide_alert')
		$Patterns.add_child(_dflt_pattern)
	
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
	if _is_killing: return

	if not _is_alert:
		$Alert.stop()
		$Alert.frame = 0
	else:
		$Tween.interpolate_property(
			self, 'alert_count',
			time_to_catch, 0,
			time_to_catch, Tween.TRANS_LINEAR, Tween.EASE_IN, 1
		)
		$Tween.connect('tween_step', self, '_on_tween_step')

# Que cuando se active zona de enemigo muestre un emoticono
func _show_alert(player_node: Node) -> void:
	if not _player_node: _player_node = player_node
	_is_alert = true
	$Tween.interpolate_property(
		$Alert, 'self_modulate:a',
		0.0, 1.0,
		0.15, Tween.TRANS_EXPO, Tween.EASE_IN
	)
	$Tween.start()
	$Alert.play('Show')

func _hide_alert() -> void:
	_player_node = null
	_is_alert = false
	$Tween.remove_all()
	$Tween.interpolate_property(
		$Alert, 'self_modulate:a',
		1.0, 0.0,
		0.1, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	$Tween.start()

func _destroy_player() -> void:
	$Tween.disconnect('tween_step', self, '_on_tween_step')
	if _is_alert:
		_is_killing = true

		# Quitar el control al jugador
		Event.emit_signal('set_control_active', false)
		
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
		$Alert.play(str(alert_count + 1))


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
