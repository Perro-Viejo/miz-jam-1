extends Area2D

func ready():
	connect('body_entered', self, '_on_body_entered')

func _on_body_entered(body: Node) -> void:
	print(body.name)
	if body.name != 'Player':
		return

	if $Treasure:
		var inventory = body.get_node("./Inventory")
		inventory.add_to_inventory($Treasure)
		inventory.add_child($Treasure)
		
		remove_child($Treasure)
