extends Node3D


@export var TargetNode: NodePath
@onready var target_node = get_node_or_null(TargetNode)

@export var RotationSpeed: float = 1.0

func _process(delta):
	if target_node and is_instance_valid(target_node):
		global_transform.origin = target_node.global_transform.origin
		# global_transform.origin.y += 1
		var x_adjustment = deg_to_rad(-10)
		rotation.x = lerp_angle(rotation.x, target_node.rotation.x + x_adjustment, delta*RotationSpeed)
		rotation.y = lerp_angle(rotation.y, target_node.rotation.y, delta*RotationSpeed)
		rotation.z = lerp_angle(rotation.z, target_node.rotation.z, delta*RotationSpeed)
