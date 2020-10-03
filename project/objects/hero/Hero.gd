extends KinematicBody
class_name Hero

signal rewind(target)

var facing : Vector3 = Vector3.FORWARD
var speed = 10  # Units per second

var slash_range_squared = 10  # Units squared distance from an enemy to be in range
var target_enemy : Enemy

onready var start_position : Vector3 = transform.origin

class PlayerInputs:
	
	var up = false
	var down = false
	var left = false
	var right = false
	
	var recording = false
	var record = []
	var playback = false
	
	func _init(playback_data:Array=[]):
		
		#We have either playback or recording
		if playback_data and playback_data.size():
			playback = true
			record = playback_data
		else:
			#No data, we must be recording then
			recording = true
		
	
	func record_state():
		if not recording:
			return
		
		var copy = PlayerInputs.new()
		copy.up = up
		copy.down = down
		copy.left = left
		copy.right = right
		record.append(copy)
	
	func playback_state(timestep:int):
		if not playback:
			return true
			
		#Do we have an action for this timestep or is the playback complete?
		var playback_complete = timestep >= record.size()
		if playback_complete:
			return true
		
		#Set our actions accordingly
		var copy = record[timestep]
		up = copy.up
		down = copy.down
		left = copy.left
		right = copy.right
		return false
	
	func update_with_event(event: InputEventKey):
		if event.is_action_pressed("player_move_up"):
			up = true
		elif event.is_action_released("player_move_up"):
			up = false
			
		if event.is_action_pressed("player_move_down"):
			down = true
		elif event.is_action_released("player_move_down"):
			down = false
			
		if event.is_action_pressed("player_move_left"):
			left = true
		elif event.is_action_released("player_move_left"):
			left = false
			
		if event.is_action_pressed("player_move_right"):
			right = true
		elif event.is_action_released("player_move_right"):
			right = false
	
	func to_vector() -> Vector3:
		
		#Apply inputs
		var z = (1 if up else 0) + (-1 if down else 0)
		var x = (1 if left else 0) + (-1 if right else 0)
		var vector = Vector3(x, 0, z)
		return vector
var player_inputs = PlayerInputs.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_unhandled_key_input(true)
	set_physics_process(true)

func _physics_process(delta):
	_process_movement(delta)
	
	_check_enemy()

func _process_movement(delta):
	#Determine the angle of movement based on the player inputs
	player_inputs.record_state()
	_apply_movement()

func _apply_movement():
	var direction = player_inputs.to_vector()
	if direction == Vector3.ZERO:
		return
	
	#Face that direction
	look_at(transform.origin + direction, Vector3.UP)
	
	#Move in the direction
	var velocity = direction * speed
	move_and_slide(velocity)

func _check_enemy():
	
	#Look through all enemies
	target_enemy = null
	for enemy in get_tree().get_nodes_in_group("enemy"):
		#Has it been killed already? Is it close enough?
		var distance = global_transform.origin.distance_squared_to(enemy.transform.origin)
		if enemy.kill_state == Enemy.EnemyKillState.IDLE and distance < slash_range_squared:
			#We can target this enemy
			#Mark targetted
			target_enemy = enemy
			enemy.highlight = true
		else:
			enemy.highlight = false

func rewind(target=null):
	#TODO: This will be painful
	
	#Reset back to the start position
	transform.origin = start_position
	
	#Announce we've begun a rewind
	emit_signal("rewind", target)
	player_inputs = PlayerInputs.new()

func _handle_slash_input(event):
	
	if event.is_action_pressed("player_slash"):
		#Do we have a target?
		if target_enemy:
			print("Player slashed!")
			rewind(target_enemy)

func _unhandled_key_input(event):
	
	_handle_slash_input(event)
	
	player_inputs.update_with_event(event)
