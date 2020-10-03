extends KinematicBody

var controlled : bool = true  # Hero is always controlled by the player

var facing : Vector3 = Vector3.FORWARD
var speed = 10  # Units per second

class PlayerInputs:
	
	var up = false
	var down = false
	var left = false
	var right = false
	
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

enum HeroState {
	PLAYING,
	SLASHING
}
var hero_state = HeroState.PLAYING

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if controlled:
		set_process_unhandled_key_input(true)
	
	set_physics_process(true)

func _physics_process(delta):
	
	_process_movement(delta)
	
		
		
	pass

func _process_movement(delta : float):
	if hero_state == HeroState.PLAYING:
		
		#Determine the angle of movement based on the player inputs
		var direction = player_inputs.to_vector()
		if direction == Vector3.ZERO:
			return
		
		#Face that direction
		look_at(transform.origin + direction, Vector3.UP)
		
		#Move in the direction
		var velocity = direction * speed
		move_and_slide(velocity)

func _handle_slash_input(event):
	
	if event.is_action_pressed("player_slash"):
		print("Player slashed!")
		pass

func _unhandled_key_input(event):
	
	_handle_slash_input(event)
	
	player_inputs.update_with_event(event)
