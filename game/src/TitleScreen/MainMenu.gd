extends CanvasLayer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export (String, FILE, '*.tscn') var First_Level: String
export (String, FILE, '*.tscn') var intro_scn: String
export(bool) var show_intro = true

var _is_credits := false

onready var _name_container: VBoxContainer = find_node('NameContainer')
onready var _buttons_container: HBoxContainer = find_node('ButtonsContainer')
onready var _new_game: Button = find_node('NewGame')
onready var _options: Button = find_node('Options')
onready var _credits_btn: Button = find_node('CreditsBtn')
onready var _exit: Button = find_node('Exit')
onready var _credits: MarginContainer = find_node('Credits')
onready var _credits_back: Button = _credits.find_node('Back')
onready var _devs: Label = find_node('Devs')
# ---- Los del "tutorial" ----
onready var _to_accelerate: Label = find_node('ToAccelerate')
onready var _to_turn: Label = find_node('ToTurn')
onready var _to_turbo: Label = find_node('ToTurbo')
onready var _goal: Label = find_node('Goal')
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready()->void:
	Event.MainMenu = true
	guiBrain.gui_collect_focusgroup()
	_credits.hide()

	if Settings.HTML5:
		_exit.visible = false

	# Conectarse a señales de los hijos
	_new_game.connect('pressed', self, '_on_NewGame_pressed')
	_options.connect('pressed', self, '_on_Options_pressed')
	_credits_btn.connect('pressed', self, '_on_Credits_pressed')
	_exit.connect('pressed', self, '_on_Exit_pressed')

	# Conectarse a señales del universo pokémon
	Settings.connect('ReTranslate', self, 'retranslate') # Localización

	retranslate()


func _process(delta):
	$BG.visible = !Event.Options


func _exit_tree()->void:
	Event.emit_signal("stop_requested", "MX", "Menu")
	Event.emit_signal("play_requested", "MX", "inGame")
	Event.MainMenu = false				#switch bool for easier pause menu detection and more
	guiBrain.gui_collect_focusgroup()	#Force re-collect buttons because main meno wont be there


func _on_NewGame_pressed()->void:
	Event.emit_signal('NewGame')
	if show_intro:
		Event.emit_signal('ChangeScene', intro_scn)
	else:
		Event.emit_signal('ChangeScene', First_Level)


func _on_Options_pressed()->void:
	Event.Options = true


func _on_Credits_pressed() -> void:
	_is_credits = !_is_credits
	if _is_credits:
		$AnimationPlayer.play('show_credits')
	else:
		$AnimationPlayer.play('credits_exit')
	yield($AnimationPlayer, 'animation_finished')
	if _is_credits:
		_credits_back.connect('pressed', self, '_on_Credits_pressed')
		_credits_back.grab_focus()
	else:
		_credits_back.disconnect('pressed', self, '_on_Credits_pressed')
		_credits_btn.grab_focus()


func _on_Exit_pressed()->void:
	Event.emit_signal('Exit')

#localization
func retranslate()->void:
	_new_game.text = tr('NEW_GAME')
	_options.text = tr('OPTIONS')
	_credits_btn.text = tr('CREDITS')
	_exit.text = tr('EXIT')
	_credits_back.text = tr('BACK')
	_to_accelerate.text = tr('TUT_ACCELERATE')
	_to_turbo.text = tr('TUT_TURBO')
	_to_turn.text = tr('TUT_TURN')
	_goal.text = tr('TUT_GOAL')
