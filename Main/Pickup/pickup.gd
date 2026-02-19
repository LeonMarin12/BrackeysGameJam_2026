extends RigidBody2D
class_name Pickup

@export_enum("healing", "sanity", "ammo") var pickup_name: String


func take_impulse(push_force, direction):
	apply_impulse(push_force * direction)
	apply_torque_impulse(push_force * direction.x )


func disappear():
	call_deferred('queue_free')
