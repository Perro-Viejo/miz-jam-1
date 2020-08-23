extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_body_entered(body: Node) -> void:
	if body.name != 'Player':
		return
	
	if "key" in body.get_node("./Inventory")._inventory:
		owner.on_win()
