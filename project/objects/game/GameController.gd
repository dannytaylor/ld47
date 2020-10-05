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
var game_over = false


onready var player : Hero = get_tree().get_nodes_in_group("player")[0]
onready var timer : Timer = Timer.new()
onready var end_camera : Camera = Camera.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#First thing we do is show the beginning slate
	yield(show_slate(StartSlateScene.instance()), "completed")
	
	#Listen for any players rewinding
	player.connect("rewind", self, "_on_player_rewind")
	set_process_unhandled_key_input(true)
	set_physics_process(true)
	time_paused = false
	
	#Add a timer
	add_child(timer)
	timer.one_shot = true
	
	#Set up the end camera
	add_child(end_camera)
	end_camera.global_transform = end_camera.global_transform.rotated(Vector3.LEFT, PI/2)
	end_camera.global_transform = end_camera.global_transform.rotated(Vector3.UP, PI)
	end_camera.global_transform.origin = Vector3(0, 40, 0)
	
func _physics_process(delta):
	if not time_paused and not game_over:
		elapsed_time += delta
		emit_signal("time_updated", elapsed_time)

func _on_player_rewind(target):
	
	#Did we kill someone?
	if target:
		
		#Add a phantom
		var playback_data = player.player_inputs.record
		var new_phantom = PhantomScene.instance()
		add_child(new_phantom)
		new_phantom.playback_data = playback_data
		new_phantom.transform.origin = player.transform.origin
		new_phantom.target_enemy = target
	
	#All enemies killed?
	time_paused = true
	var remaining_enemies = update_remaining_enemies()
	if remaining_enemies < 1:
		#We're done. Show end slate and then move to credits
		yield(show_slate(CompleteSlateScene.instance()), "completed")
		
		#Move to end of game
		game_end()
		
	else:
		if target:
			#There was a kill, show the mid slate
			yield(show_slate(KillSlateScene.instance()), "completed")
		else:
			#Plain restart, got caught or something
			yield(show_slate(RestartSlateScene.instance()), "completed")
		
		#We rewind
		emit_signal("rewind")
	
	#Done with this, no longer pause
	time_paused = false

func game_end():
	
	#Kill the player, its all ghosts now
	player.queue_free()
	end_camera.current = true
	
	#Hide the regular UI
	$UI.visible = false
	
	#Show the end UI
	$EndUI.visible = true
	time_paused = true
	game_over = true
	
	var minutes = int(elapsed_time) / (60)
	var seconds = int(elapsed_time) % (60)
	var time_string = "%s:%02d" % [minutes, seconds]
	$EndUI/Label.text = time_string
	
	#Connect contract enders
	for phantom in get_tree().get_nodes_in_group("phantom"):
		phantom.connect("contract_complete", self, "_on_contract_complete")
	
	replay_everything()

func _on_contract_complete():
	
	#Are they all complete?
	for phantom in get_tree().get_nodes_in_group("phantom"):
		
		#Is it done?
		if not phantom.playback_paused:
			return
	
	#All complete, go again
	#Wait a little longer for dramatic effect
	timer.start(3)
	yield(timer, "timeout")
	
	#And go again
	replay_everything()

func replay_everything():
	emit_signal("rewind")

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
