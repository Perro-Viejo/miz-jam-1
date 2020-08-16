class_name VisibilityZone
extends Area2D

signal player_seen(player_node)

export(Texture) var active

onready var _normal: Texture = $Zone.texture

func _ready():
	connect('body_entered', self, '_on_body_entered')
	connect('body_exited', self, '_on_body_exited')

func _on_body_entered(body: Node) -> void:
	if body.name == 'Player':
		Event.emit_signal("play_requested", "UI", "DangerZone")
		$Zone.texture = active
		emit_signal('player_seen', body)

func _on_body_exited(body: Node) -> void:
	if body.name == 'Player':
		$Zone.texture = _normal
		emit_signal('player_seen', null)
