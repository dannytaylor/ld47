extends Spatial

signal rewind()
signal enemies_remaining(count)
signal time_updated(time)

const PhantomScene = preload("res://objects/hero/Phantom.tscn")
const KillSlateScene = preload("res://scenes/mid-slates/KillSlate.tscn")
const StartSlateScene = preload("res://scenes/mid-slates/StartSlate.tscn")
const CompleteSlateScene = preload("res://scenes/mid-slates/CompleteSlate.tscn")
const RestartSlateScene = preload("res://scenes/mid-slates/RestartSlate.tscn")

var elapsed_time = 0
var time_paused = true

onready var player : Hero = get_tree().get_nodes_in_group("player")[0]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#First thing we do is show the beginning slate
	yield(show_slate(StartSlateScene.instance()), "completed")
	
	#Listen for any players rewinding
	player.connect("rewind", self, "_on_player_rewind")
	set_process_unhandled_key_input(true)
	set_physics_process(true)
	time_paused = false

func _physics_process(delta):
	if not time_paused:
		elapsed_time += delta
		emit_signal("time_updated", elapsed_time)

func _on_player_rewind(target):
	
	#All enemies killed?
	time_paused = true
	var remaining_enemies = update_remaining_enemies()
	if remaining_enemies < 1:
		#We're done. Show end slate and then move to credits
		yield(show_slate(CompleteSlateScene.instance()), "completed")
		
		#Move to end of game
		
	else:
		#We need to spawn a new phantom if the player 'got the kill'
		if target:
			
			#Add a kill slate
			var playback_data = player.player_inputs.record
			yield(show_slate(KillSlateScene.instance()), "completed")
			
			
			var new_phantom = PhantomScene.instance()
			add_child(new_phantom)
			new_phantom.playback_data = playback_data
			new_phantom.transform.origin = player.transform.origin
			new_phantom.target_enemy = target
		else:
			
			#Plain restart, got caught or something
			yield(show_slate(RestartSlateScene.instance()), "completed")
		
		#We rewind
		emit_signal("rewind")
	
	#Done with this, no longer pause
	time_paused = false


func show_slate(slate):
	
	#Add the slate
	add_child(slate)
	get_tree().paused = true
	yield(slate, "complete")
	get_tree().paused = false
	remove_child(slate)
	slate.queue_free()

func update_remaining_enemies():
	var count = 0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.kill_state == Enemy.EnemyKillState.IDLE:
			count += 1
	emit_signal("enemies_remaining", count)
	return count

func _unhandled_key_input(event):
	if event.is_action_pressed("player_restart"):
		get_tree().reload_current_scene()
