tool
extends Node2D

export var car_animations: SpriteFrames
export var shake_amount := 0.4

var _shaking := true
var _dflt_position: Vector2

func _ready() -> void:
	_dflt_position = $AnimatedSprite.position
	$AnimatedSprite.play('Idle')
	$AnimatedSprite.frames = car_animations
	Event.connect('game_ended', self, '_dance')

func _process(delta) -> void:
	if _shaking:
		$AnimatedSprite.position = _dflt_position + Vector2(
			rand_range(-1.0, 1.0) * shake_amount,
			rand_range(-1.0, 1.0) * shake_amount
		)

func _dance() -> void:
	_shaking = false
	$AnimatedSprite.play('Dance')
