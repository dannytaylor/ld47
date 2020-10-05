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
	get_tree().get_nodes_in_group("gamecontroller")[0].connect("rewind", self, "_on_GameController_rewind")
	set_process(true)
	$enemy/AnimationPlayer.play("stand")
	
	
func _process(delta):
	
	#Update the radius shader
	var shader = $MeshInstance.mesh.surface_get_material(0)
	
	if player:
		shader.set_shader_param("SourcePosition", player.global_transform.origin)
		shader.set_shader_param("MaxDistance", player.view_distance)
	else:
		shader.set_shader_param("MaxDistance", 10000)
	

func rewind():
	
	#Stop animations
	$Alert.visible = false
	$Area.visible = true
	$Area.monitoring = true
	
	#Reset position just in case
	$AudioStreamPlayer.stop()
	$enemy/AnimationPlayer.play("stand")
	$enemy/AnimationPlayer.play("default")
	transform = start_transform
	$CPUParticles.emitting = false
	$CPUParticles.visible = false
	$CPUParticles.restart()
	
	$Killed.visible = kill_state == EnemyKillState.PREVIOUSLY_KILLED
	

func kill():
	#Mark as dead
	$Area.visible = false
	$Area.monitoring = false
	kill_state = EnemyKillState.PREVIOUSLY_KILLED
	
	#Play death animation
	$AudioStreamPlayer.play()
	$enemy/AnimationPlayer.play("death")
	$CPUParticles.emitting = true
	$CPUParticles.visible = true

func _on_GameController_rewind():
	
	#Kick off the rewind sequence
	rewind()


func _on_Area_body_entered(body):
	
	#Was it the player?
	if body.is_in_group("player"):
		#We got 'em
		body.caught(self)
		$enemy/AnimationPlayer.play("spotted")
		$Alert.visible = true
	
	pass # Replace with function body.
