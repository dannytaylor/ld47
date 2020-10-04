extends Hero

var playback_data : Array = [] setget _set_playback_data
var playback_timestep : int = 0
var playback_paused : bool = true

func _ready():
	._ready()
	set_process_unhandled_key_input(false)
	start_playback()
	
	#Listen for any players rewinding
	var player = get_tree().get_nodes_in_group("player")[0]
	player.connect("rewind", self, "_on_player_rewind")

func _set_playback_data(_playback_data):
	playback_data = _playback_data
	player_inputs = PlayerInputs.new(playback_data)

func _process_movement(delta : float):
	
	#Set the recording to the right playback step
	if not playback_paused:
		var done = player_inputs.playback_state(playback_timestep)
		playback_timestep += 1
		
		_apply_movement()
		
		#If we are done, stop time and kill our target
		if done:
			playback_paused = true
			target_enemy.kill()
		

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
	
	#Reset back to the start position
	transform.origin = start_position
	
	#Start the playback again
	start_playback()

func _on_player_rewind(successful):
	
	#Kick off the rewind sequence
	rewind()

