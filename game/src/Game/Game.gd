extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
signal SceneIsLoaded

enum {IDLE, FADEOUT, FADEIN}

const transition_duration := 1.2

onready var CurrentScene = null
onready var CurrentSceneInstance = $Levels.get_child($Levels.get_child_count() - 1)
var NextScene
var FadeState:int = IDLE
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready()->void:
	Data.set_data(Data.CURRENT_SCENE, 'MainMenu')

	Event.connect("Options",	self, "on_Options")
	Event.connect("Exit",		self, "on_Exit")
	Event.connect("ChangeScene",self, "on_ChangeScene")
	Event.connect("Restart", 	self, "restart_scene")
	#Background loader
	SceneLoader.connect("scene_loaded", self, "on_scene_loaded")
	#SceneLoader.load_scene("res://Levels/TestScene.tscn", {instructions="for what reason it got loaded"})

	# Perro Viejo
	Event.connect('music_requested', self, 'play_song')
	Event.connect('music_stoped', $Music, 'stop')

	guiBrain.gui_collect_focusgroup()

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	Event.emit_signal("play_requested", "MX", "Menu")


func on_Options(options) -> void:
	guiBrain.gui_collect_focusgroup()


func on_ChangeScene(scene):
	if FadeState != IDLE:
		return

	if Settings.HTML5:
		NextScene = load(scene)
	else:
		SceneLoader.load_scene(scene, {scene="Level"})

	FadeState = FADEOUT

	$FadeLayer/FadeTween.interpolate_property(
		$FadeLayer,
		"percent",
		0.0,
		1.0,
		transition_duration,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT,
		0.0
	)
	$FadeLayer/FadeTween.start()
	Event.emit_signal("play_requested", "UI", "Transition_Up")

func on_Exit()->void:
	if FadeState != IDLE:
		return
	get_tree().quit()

func on_scene_loaded(Loaded)->void:
	NextScene = Loaded.resource
	emit_signal("SceneIsLoaded")	#Scene fade signal in case it loads longer than fade out

func change_scene()->void:
	 #handle actual scene change
	if NextScene == null:
		return
	yield(get_tree(), "idle_frame") #continue on idle frame
	CurrentSceneInstance.free()
	CurrentScene = NextScene
	NextScene = null
	CurrentSceneInstance = CurrentScene.instance()
	$Levels.add_child(CurrentSceneInstance)
	Data.set_data(Data.CURRENT_SCENE, CurrentSceneInstance.name)
	if CurrentSceneInstance.name == 'MainMenu':
		Event.emit_signal("play_requested", "MX", "Menu")

func restart_scene():
	if FadeState != IDLE:
		return
	yield(get_tree(), "idle_frame")
	CurrentSceneInstance.free()
	CurrentSceneInstance = CurrentScene.instance()
	$Levels.add_child(CurrentSceneInstance)

func _on_FadeTween_tween_completed(object, key)->void:
	match FadeState:
		IDLE:
			pass
		FADEOUT:
			if NextScene == null:
				print("Not loaded, please wait!")
				yield(self, "SceneIsLoaded")
			change_scene()
			FadeState = FADEIN
			Event.emit_signal("play_requested", "UI", "Transition_Down")
			$FadeLayer/FadeTween.interpolate_property(
				$FadeLayer,
				"percent",
				1.0,
				0.0,
				transition_duration * 0.4,
				Tween.TRANS_SINE,
				Tween.EASE_IN,
				0.0
			)
			$FadeLayer/FadeTween.start()
		FADEIN:
			FadeState = IDLE

func play_song(mx: AudioStream) -> void:
	$Music.stream = mx
	$Music.play()
