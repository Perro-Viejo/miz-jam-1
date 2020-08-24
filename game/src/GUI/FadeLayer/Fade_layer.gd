extends CanvasLayer

export var max_scale := 50

var percent:float = 0 setget set_percent

func set_percent(value:float)->void:
	percent = clamp(value, 0.0, 1.0)
	#Fade logic
#	$ColorRect.modulate.a = percent
	$Overlay.rect_position = Vector2(0, 180 - (180 * percent))

func _ready()->void:
#	$ColorRect.modulate.a = percent
	$Overlay.rect_position = Vector2(0, 180)
