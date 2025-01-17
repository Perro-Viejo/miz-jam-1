extends CanvasLayer

export (String, FILE, "*.tscn") var Main_Menu: String

func _ready()->void:
	Data.set_data(Data.MAIN_MENU_SCN, Main_Menu)
	
	Event.connect("Paused", self, "on_show_paused")
	Event.connect("Options", self, "on_show_options")
	Event.Paused = false
	Settings.connect("ReTranslate", self, "retranslate") # Localización

func on_show_paused(value:bool)->void:
	#Signals allow each module have it's own response logic
	$Control.visible = value
	get_tree().paused = value

func on_show_options(value:bool)->void:
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	if !Event.MainMenu:
		$Control.visible = !value

func _on_Resume_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	Event.Paused = false #setget triggers signal and responding to it hide GUI

func _on_Restart_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	Event.emit_signal("Restart")
	Event.Paused = false #setget triggers signal and responding to it hide GUI

func _on_Options_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	Event.Options = true

func _on_MainMenu_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	Event.emit_signal("ChangeScene", Data.get_data(Data.MAIN_MENU_SCN))
	Event.Paused = false

func _on_Exit_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	Event.emit_signal("Exit")

func retranslate()->void:
	find_node("Resume").text = tr("RESUME")
	find_node("Restart").text = tr("RESTART")
	find_node("Options").text = tr("OPTIONS")
	find_node("MainMenu").text = tr("MAIN_MENU")
	find_node("Exit").text = tr("EXIT")









