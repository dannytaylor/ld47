extends Camera


onready var target : Spatial = get_tree().get_nodes_in_group("player")[0]
onready var target_offset : Vector3 = target.global_transform.origin - global_transform.origin

var track_speed = 2  # How much of the distance remaining to move per frame

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_process(true)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#Move to the expected offset
	if target == null:
		queue_free()
		return
	
	var target_origin = target.global_transform.origin - target_offset
	var target_distance = global_transform.origin - target_origin
	global_transform.origin -= target_distance * track_speed * delta

	#Face towards the player
	look_at(target.global_transform.origin, Vector3.UP)


func _on_Game_rewind():
	global_transform.origin = target.global_transform.origin - target_offset
