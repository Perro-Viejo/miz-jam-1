tool
class_name Enemy
extends Node2D

export(PackedScene) var default_pattern
export(PackedScene) var right_pattern
export(Texture) var sprite

var _dflt_pattern: VisibilityPattern = null
var _is_alert := false

onready var _anchors: Dictionary = {
	n = $Anchors/North,
	e = $Anchors/East,
	s = $Anchors/South,
	w = $Anchors/West
}

func _ready():
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
	if not _is_alert:
		$Alert.stop()
		$Alert.frame = 0

# Que cuando se active zona de enemigo muestre un emoticono
func _show_alert() -> void:
	_is_alert = true
	$Tween.interpolate_property(
		$Alert,
		'self_modulate:a',
		0.0, 1.0,
		0.15, Tween.TRANS_EXPO, Tween.EASE_IN
	)
	$Tween.start()
	$Alert.play('Show')

func _hide_alert() -> void:
	_is_alert = false
	$Tween.interpolate_property(
		$Alert,
		'self_modulate:a',
		1.0, 0.0,
		0.1, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	$Tween.start()
	

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

