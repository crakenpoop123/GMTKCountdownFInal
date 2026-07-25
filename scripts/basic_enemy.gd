extends CharacterBody2D


const SPEED = 50.0


func _physics_process(delta: float) -> void:
	
	if globals.is_currently_rewinding:
		return
	
	
	if global_position.distance_to(get_node("/root/MainLevel/Player").global_position) >= 2000:
		queue_free()
	
	var player_angle = self.get_angle_to(get_node("/root/MainLevel/Player").global_position)
	#print(player_angle)
	velocity = SPEED * Vector2(cos(player_angle), sin(player_angle))
	
	move_and_slide()

func shot():
	globals.enemy_spawn_rate *= 1.01
	
	#print("enemy spawn rate", globals.enemy_spawn_rate)
	if globals.enemy_spawn_rate > 5:
		globals.enemy_spawn_rate = 5
	
	globals.total_enemies -= 1
	globals.enemies_killed += 1
	
	queue_free()
