extends Control

onready var game_controller = get_tree().get_nodes_in_group("gamecontroller")[0]
onready var icon_ghost = preload("res://img/icon_ghost.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Connect to the game controller events
	game_controller.connect("enemies_remaining", self, "_on_gamecontroller_enemies_remaining")
	game_controller.connect("time_updated", self, "_on_gamecontroller_time_updated")

func _on_gamecontroller_enemies_remaining(count):
	var iconswap = get_node("HBoxContainer/icon" + str(7 - count))
	iconswap.texture = icon_ghost
	
	
	
func _on_gamecontroller_time_updated(time):
	var minutes = int(time) / (60)
	var seconds = int(time) % (60)
	var time_string = "%s:%02d" % [minutes, seconds]
	$Time.text = time_string
