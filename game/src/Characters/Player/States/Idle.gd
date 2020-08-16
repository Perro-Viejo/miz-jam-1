extends "res://src/StateMachine/State.gd"

onready var _owner: Player = owner

func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	Event.emit_signal("stop_requested", "Boat", "Loop")
	_owner.play_animation()

func exit() -> void:
	.exit()
