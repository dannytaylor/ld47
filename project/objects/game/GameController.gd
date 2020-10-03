extends Spatial

const PhantomScene = preload("res://objects/hero/Phantom.tscn")

onready var player : Hero = get_tree().get_nodes_in_group("player")[0]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Listen for any players rewinding
	player.connect("rewind", self, "_on_player_rewind")


func _on_player_rewind(target):
	
	#We need to spawn a new phantom if the player 'got the kill'
	if target:
		var playback_data = player.player_inputs.record
		var new_phantom = PhantomScene.instance()
		add_child(new_phantom)
		new_phantom.playback_data = playback_data
		new_phantom.transform.origin = player.transform.origin
		new_phantom.target_enemy = target
	else:
		#Plain restart, got caught or something
		pass
