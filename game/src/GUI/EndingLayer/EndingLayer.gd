extends CanvasLayer

var _text_wave := '\n[right][wave amp=70 freq=4]%s[/wave][/right]'
var _win_text := ''

onready var _main_menu_btn: Button = find_node('GoToMainMenu')
onready var _rich_text_lbl: RichTextLabel = find_node('WinMessage')

func _ready() -> void:
	$Control.hide()
	guiBrain.gui_collect_focusgroup()
	retranslate()

	# Conectarse a señales de los hijos
	_main_menu_btn.connect('pressed', self, '_go_to_main_menu')
	
	# Conectarse a señales del mundo pokémon
	Event.connect('game_ended', self, '_show')
	Settings.connect('ReTranslate', self, 'retranslate') # Localización

func _show() -> void:
	$Control.show()
	Event.ended = true
	guiBrain.force_focus()

func _go_to_main_menu() -> void:
	Event.emit_signal("stop_requested", "MX", "Win")
	Event.ended = false
	$Control.hide()
	Event.emit_signal("ChangeScene", Data.get_data(Data.MAIN_MENU_SCN))

func retranslate()->void:
	_main_menu_btn.text = tr("MAIN_MENU")
	_win_text = _text_wave % tr('WIN')
	_rich_text_lbl.bbcode_text = _win_text
