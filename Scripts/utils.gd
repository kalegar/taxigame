class_name Utils
extends Node

static func get_point_velocity(point:Vector3, linear_vel:Vector3, angular_vel:Vector3, relative_body_global_position:Vector3) -> Vector3:
	return linear_vel - angular_vel.cross(point - relative_body_global_position)
