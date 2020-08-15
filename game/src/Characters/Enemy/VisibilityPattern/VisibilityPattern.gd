class_name VisibilityPattern
extends Node2D

signal player_entered
signal player_left

var _active_zones := 0

func _ready():
	for zone in $Zones.get_children():
		var v_zone: VisibilityZone = zone
		v_zone.connect('player_seen', self, '_on_player_seen')

func _on_player_seen(seen: bool) -> void:
	if seen:
		if _active_zones == 0:
			emit_signal('player_entered')
		_active_zones += 1
	else:
		_active_zones -= 1
		if _active_zones == 0:
			emit_signal('player_left')
