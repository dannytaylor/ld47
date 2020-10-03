extends Spatial
class_name Enemy

const enemy_material = preload("res://objects/enemy/enemy_material.tres")
const highlight_material = preload("res://objects/enemy/outline_material.tres")

var highlight : bool = false setget _set_highlight

enum EnemyKillState {
	IDLE,
	PREVIOUSLY_KILLED
}
var kill_state = EnemyKillState.IDLE

onready var start_position : Vector3 = transform.origin

func _set_highlight(_highlight):
	highlight = _highlight
	var new_material = highlight_material if highlight else null
	$MeshInstance.material_override = new_material

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Listen for any players rewinding
	var player = get_tree().get_nodes_in_group("player")[0]
	player.connect("rewind", self, "_on_player_rewind")
	
	pass # Replace with function body.

func rewind():
	
	#TODO: If we are dying/dead play the animation backwards
	
	#TODO: If we caught the player, play animation backwards
	
	#Reset position just in case
	transform.origin = start_position
	#$AnimationPlayer.play("idle")

func kill():
	#Mark as dead
	kill_state = EnemyKillState.PREVIOUSLY_KILLED
	
	#Play death animation
	$AnimationPlayer.play("die")

func _on_player_rewind(successful):
	
	#Kick off the rewind sequence
	rewind()
