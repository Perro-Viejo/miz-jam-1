extends Panel
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
onready var _master:VBoxContainer = find_node('Master')
onready var _music:VBoxContainer = find_node('Music')
onready var _sfx:VBoxContainer = find_node('SFX')
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	_master.connect('value_changed', self, '_on_Master_value_changed')
	_music.connect('value_changed', self, '_on_Music_value_changed')
	_sfx.connect('value_changed', self, '_on_SFX_value_changed')

func _on_Master_value_changed(value: float):
#	if SetUp:
#		return
	Settings.VolumeMaster = value/100
	var player:AudioStreamPlayer = find_node('Master').get_node('AudioStreamPlayer')
	player.stream = preLoad.snd_TestBeep
	player.play()

func _on_Music_value_changed(value: float):
#	if SetUp:
#		return
	Settings.VolumeMusic = value/100
	var player:AudioStreamPlayer = find_node('Music').get_node('AudioStreamPlayer')
	player.stream = preLoad.snd_TestBeep
	player.play()

func _on_SFX_value_changed(value: float):
#	if SetUp:
#		return
	Settings.VolumeSFX = value/100
	var player:AudioStreamPlayer = find_node('SFX').get_node('AudioStreamPlayer')
	player.stream = preLoad.snd_TestBeep
	player.play()
