extends KinematicBody2D

signal died()

export(Color) var dialog_color
export(int) var health = 0
export(bool) var immortal = false

var _in_dialog := false
export(int) var max_health = 0

onready var inventory = $Inventory
onready var state_machine = $StateMachine
