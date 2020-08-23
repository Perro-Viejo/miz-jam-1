extends RigidBody2D
class_name Bomb

const SPLASH = preload("res://src/Particles/BombSplashParticle.tscn")

var particle

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("Idle")
	set_bounce(0)
	set_friction(1)
	sleeping = true


func _on_body_entered(area):
	if area.get_name() == "Player" or "Bomb" in area.get_name():
		$ExplosionShape.get_node("./Sprite").visible = true
		$AnimatedSprite.play("Twinkle")
		Event.emit_signal("play_requested", "Bomb", "Hit")
		Event.emit_signal("play_requested", "Bomb", "Activate")

func _on_animation_finished():
	if $AnimatedSprite.animation == "Twinkle":
		var particle = SPLASH.instance()
		get_parent().add_child(particle)
		particle.set_global_position(global_position)
		Event.emit_signal("play_requested", "Bomb", "Explode")
		for area in $ExplosionShape.get_overlapping_areas():
			if area.owner.get_name() == "Player":
				Event.emit_signal("player_killed")
		
		queue_free()
