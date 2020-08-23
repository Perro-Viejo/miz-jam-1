extends Area2D


func ready():
	connect('body_entered', self, '_on_body_entered')


func _on_body_entered(body: Node) -> void:
	if body.name != 'Player':
		return
	
	if has_node("Treasure"):
		var inventory = body.get_node("./Inventory")
		var treasure = get_node("./Treasure")
		
		remove_child(treasure)
		treasure.queue_free()
		
		inventory.add_child(treasure)
		inventory.add_to_inventory(treasure)
		
		Event.emit_signal('play_requested', 'Boat', 'Grab')
