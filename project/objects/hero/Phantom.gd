extends Hero

signal contract_complete
var playback_data : Array = [] setget _set_playback_data
var playback_timestep : int = 0
var playback_paused : bool = true
var killcomplete
var mat

func _ready():
	._ready()
	set_process_unhandled_key_input(false)
	start_playback()
	
	var killcomplete = false
	#Listen for any players rewinding
	var game = get_tree().get_nodes_in_group("gamecontroller")[0]
	game.connect("rewind", self, "_on_player_rewind")
	mat = $"character/Armature/Bone/Bone001/Bone002/Bone003/Bone004/Head001".get_surface_material(0)

func _set_playback_data(_playback_data):
	playback_data = _playback_data
	player_inputs = PlayerInputs.new(playback_data)

func _process(delta):
	if killcomplete:
		mat.params_grow_amount = mat.params_grow_amount + 0.08
	else:
		mat.params_grow_amount = max(mat.params_grow_amount - 0.5,0.0)
	
func _process_movement(delta : float):
	
	#Set the recording to the right playback step
	if not playback_paused:
		var done = player_inputs.playback_state(playback_timestep)
		playback_timestep += 1
		
		_apply_movement()
		
		#If we are done, stop time and kill our target
		if done:
			playback_paused = true
			_animate_slash()
			emit_signal("contract_complete")

func _animate_slash():
	
	#Face towards the enemy
	player_controllable = false
	look_at(target_enemy.global_transform.origin, Vector3.UP)
	
	$character/AnimationPlayer.play("char_atk")
	
	#Pause for dramatic effect
	$Timer.start(0.7)
	yield($Timer, "timeout")
	
	killcomplete = true
	
	target_enemy.kill()
	$Timer.start(0.7)
	yield($Timer, "timeout")
	

func _check_enemy():
	return

func start_playback():
	
	#First, wait a bit
	playback_paused = true
	$DelayTimer.start()
	yield($DelayTimer, "timeout")
	
	#Start playback
	player_inputs = PlayerInputs.new(playback_data)
	playback_timestep = 0
	playback_paused = false

func rewind(successful=true):
	#TODO: This will be painful
	killcomplete = false
	
	#Reset back to the start position
	transform.origin = start_position
	
	#Start the playback again
	start_playback()

func _on_player_rewind():
	
	#Kick off the rewind sequence
	rewind()

