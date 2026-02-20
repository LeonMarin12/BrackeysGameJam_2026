extends RigidBody2D
class_name Pickup

@export_enum("healing", "sanity", "ammo") var pickup_name: String
@export var value :int = 10

func take_impulse(push_force, direction):
	apply_impulse(push_force * direction)
	apply_torque_impulse(push_force * randf_range(-1.0, 1.0))


func disappear():
	call_deferred('queue_free')
