extends CharacterBody2D


const BULLETSPEED = 1000.0

var angle = 0

func _physics_process(delta: float) -> void:
	if globals.is_currently_rewinding:
		return
	
	if global_position.distance_to(get_node("/root/MainLevel/Player").global_position) >= 2000:
		queue_free()
	
	velocity = BULLETSPEED * Vector2(cos(angle), sin(angle))
	
	rotation = angle
	
	# Check if it hits an enemy
	for collision in get_slide_collision_count():
		var collider = get_slide_collision(collision)
		#print(collider.get_collider().name)
		if collider.get_collider().has_method("shot"):
			collider.get_collider().shot()
			queue_free()
	
	move_and_slide()
