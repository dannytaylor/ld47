extends Spatial

onready var play_button = $UI/play_button
onready var play_shadow1 = $UI/play_button/play_shadow1
onready var play_shadow2 = $UI/play_button/play_shadow2

var text_speed = 40
var text_offset = 240

func _ready():
	set_process(true)
	
func _process(delta):
	if play_button.is_hovered():
		if play_shadow1.rect_position.x < text_offset:
			play_shadow1.rect_position.x += text_speed
		if play_shadow2.rect_position.x > -text_offset:
			play_shadow2.rect_position.x += -text_speed	
	else:
		if play_shadow1.rect_position.x > 0:
			play_shadow1.rect_position.x += -text_speed
		if play_shadow2.rect_position.x < 0:
			play_shadow2.rect_position.x += text_speed
		
		

func _on_play_button_mouse_entered():
	pass


func _on_play_button_pressed():
	get_tree().change_scene("res://scenes/DevinTest.tscn")
