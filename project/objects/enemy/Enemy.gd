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

onready var start_transform : Transform = transform
onready var player = get_tree().get_nodes_in_group("player")[0]

func _set_highlight(_highlight):
	highlight = _highlight
	var new_material = highlight_material if highlight else null
	$MeshInstance.material_override = new_material

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Listen for any players rewinding
	get_parent().connect("rewind", self, "_on_GameController_rewind")
	set_process(true)

func _process(delta):
	
	#Update the radius shader
	var shader = $MeshInstance.mesh.surface_get_material(0)
	shader.set_shader_param("SourcePosition", player.global_transform.origin)
	shader.set_shader_param("MaxDistance", player.view_distance)
	
	

func rewind():
	
	#Stop animations
	$Area.visible = true
	$Area.monitoring = true
	$AnimationPlayer.stop()
	
	#Reset position just in case
	transform = start_transform
	

func kill():
	#Mark as dead
	$Area.visible = false
	$Area.monitoring = false
	kill_state = EnemyKillState.PREVIOUSLY_KILLED
	
	#Play death animation
	$AnimationPlayer.play("die")

func _on_GameController_rewind():
	
	#Kick off the rewind sequence
	rewind()


func _on_Area_body_entered(body):
	
	#Was it the player?
	if body.is_in_group("player"):
		#We got 'em
		body.caught(self)
	
	pass # Replace with function body.
