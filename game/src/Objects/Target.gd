extends Node2D

onready var player = get_parent().get_node("Player")
export(int) var speed = 1
var started = false
var shot = false

func _ready():
	Event.connect("target_deployed", self, "_on_target_deployed")
	visible = false
	$AnimatedSprite.play("Idle")
	
func _process(delta):
	if Data.get_data(Data.LEVEL_FINISHED):
		started = false
		visible = false
		Event.emit_signal("stop_requested", "UI", "Scope")
	if started: 
		var player_direction = (player.global_position - global_position).normalized()
		global_position += player_direction * speed
		
		if player.global_position.distance_to(global_position) < 5:
			global_position = player.global_position
			$AnimatedSprite.play("AtakitakiRumba")
			
			if not shot:
				$Timer.start()
				shot = true

func _on_target_deployed(start_position):
	Event.emit_signal("play_requested", "UI", "Scope")
	visible = true
	started = true
	global_position = Utils.get_screen_coords_for(start_position)


func _on_Timer_timeout():
	print("player dieeee")
	Event.emit_signal("player_killed")
	Event.emit_signal("stop_requested", "UI", "Scope")
