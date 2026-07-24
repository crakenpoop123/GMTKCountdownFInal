extends CharacterBody2D


const SPEED = 300.0

var target_speed: Vector2 = Vector2(0, 0)

var bullet = preload("res://scenes/bullet.tscn")


func _physics_process(delta: float) -> void:
	
	
	# Vertical movement
	if Input.is_action_pressed("up") && Input.is_action_pressed("down"):
		target_speed[1] = 0
	elif Input.is_action_pressed("up"):
		target_speed[1] = -SPEED
	elif Input.is_action_pressed("down"):
		target_speed[1] = SPEED
	else:
		target_speed[1] = 0
	
	# Horizontal movement
	if Input.is_action_pressed("left") && Input.is_action_pressed("right"):
		target_speed[0] = 0
	elif Input.is_action_pressed("left"):
		target_speed[0] = -SPEED
	elif Input.is_action_pressed("right"):
		target_speed[0] = SPEED
	else:
		target_speed[0] = 0
	
	
	# Make the player slower if they are moving diagonally
	if (Input.is_action_pressed("up") != Input.is_action_pressed("right")) && (Input.is_action_pressed("up") != Input.is_action_pressed("down")):
		target_speed[0] /= sqrt(2)
		target_speed[1] /= sqrt(2)
	
	# Smoothly chnage the players velocity
	velocity.x += (target_speed[0] - velocity.x)/globals.movement_smoothing
	velocity.y += (target_speed[1] - velocity.y)/globals.movement_smoothing
	
	if Input.is_action_pressed("attack"):
		shoot()
	
	move_and_slide()


func shoot():
	if $BulletTimer.time_left == 0:
		var shoot_angle = self.get_angle_to(get_global_mouse_position())
		
		var shot_bullet = bullet.instantiate()
		
		shot_bullet.angle = shoot_angle
		shot_bullet.global_position = self.global_position
		
		get_node("/root/MainLevel/Bullets").add_child(shot_bullet)
		$BulletTimer.start(globals.shoot_speed)
	
