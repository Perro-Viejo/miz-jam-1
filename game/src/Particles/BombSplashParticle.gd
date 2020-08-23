extends CPUParticles2D

func _ready():
	set_emitting(true)
	$Splash_1.set_emitting(true)
	$Splash_2.set_emitting(true)

func _process(delta):
	if not is_emitting():
		queue_free()


