extends CharacterBody2D


const SPEED = 50.0


func _physics_process(delta: float) -> void:
	
	var player_angle = self.get_angle_to(get_node("/root/MainLevel/Player").global_position)
	#print(player_angle)
	velocity = SPEED * Vector2(cos(player_angle), sin(player_angle))
	
	move_and_slide()

func shot():
	globals.enemy_spawn_rate *= 1.01
	queue_free()
