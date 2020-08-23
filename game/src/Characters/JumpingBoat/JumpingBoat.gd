extends Node2D

func _ready() -> void:
	$AnimatedSprite.play('Idle')
	$Camera2D.current = false


func jump() -> void:
	$AnimatedSprite.play('Jump')


func dance() -> void:
	$AnimatedSprite.play('Dance')
