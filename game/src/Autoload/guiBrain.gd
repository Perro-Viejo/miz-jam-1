extends Node

signal newScrollContainerButton

###Probably all GUI controlling functions will be there to separate mixing functions

onready var FocusDetect:Control = Control.new() #Use to detect if no button in focus
var FocusGroup:Array
var ButtonsSections:Dictionary = {}
var previous_focus:Button

func _ready()->void:
	add_child(FocusDetect) #Without this it can't detect buttons in focus
	
	pause_mode = Node.PAUSE_MODE_PROCESS
	set_process_unhandled_key_input(true)
	Event.connect("Refocus", self, "force_focus")

func gui_collect_focusgroup()->void:	#Workaround to get initial focus
	FocusGroup.clear()
	FocusGroup = get_tree().get_nodes_in_group("FocusGroup")
	for btn in FocusGroup: #Save references to call main buttons in sections
		var groups:Array = btn.get_groups()
		if groups.has("MainMenu"):
			ButtonsSections["MainMenu"] = btn
		if groups.has("Pause"):
			ButtonsSections["Pause"] = btn
		if groups.has("OptionsMain"):
			ButtonsSections["OptionsMain"] = btn
		if groups.has("OptionsControls"):
			ButtonsSections["OptionsControls"] = btn
		if groups.has("DialogMenu"):
			ButtonsSections["DialogMenu"] = btn
		if groups.has('EndingMenu'):
			ButtonsSections['EndingMenu'] = btn
	# Para que por defecto se seleccione la primera opción de cualquier menú que
	# se abra por aquí
	force_focus()

func _unhandled_input(event: InputEvent)->void:
	if event.is_action_pressed("ui_cancel"):
		if !Event.MainMenu:			#not in main menu
			if !Event.Paused:
				Event.Paused = true
			elif !Event.Options:
				Event.Paused = false
	elif FocusDetect.get_focus_owner() != null:	# There's already button in focus
		return
	elif event.is_action_pressed("ui_right"):
		Event.emit_signal("Refocus")
	elif event.is_action_pressed("ui_left"):
		Event.emit_signal("Refocus")
	elif event.is_action_pressed("ui_up"):
		Event.emit_signal("Refocus")
	elif event.is_action_pressed("ui_down"):
		Event.emit_signal("Refocus")


func _input(event):
	if Event.MainMenu and event.is_pressed():
		Event.emit_signal("play_requested", "UI", "Button")


func force_focus():
	var btn:Button
	
	# TODO: Cambiar esta mierda por un match
	if Event.MainMenu:
		if Event.Options:
			if Event.Controls:
				btn = ButtonsSections.OptionsControls
			else:
				btn = ButtonsSections.OptionsMain
		else:
			btn = ButtonsSections.MainMenu
	else:
		if Event.Options:
			if Event.Controls:
				btn = ButtonsSections.OptionsControls
			else:
				btn = ButtonsSections.OptionsMain
		else:
			if Event.Paused:
				btn = ButtonsSections.Pause
			elif Event.dialog:
				btn = ButtonsSections.DialogMenu
			elif Event.ended:
				btn = ButtonsSections.EndingMenu
	if btn != null:
		btn.grab_focus()
		
