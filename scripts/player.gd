extends CharacterBody2D


const SPEED = 300.0

var target_speed: Vector2 = Vector2(0, 0)

var bullet = preload("res://scenes/bullet.tscn")

@onready var rewinder = $PlayerRewind

func _physics_process(delta: float) -> void:
	#if Input.is_action_just_pressed("rewind"):
		#print("Player Rewind History: ", str(rewinder.rewind_values.size()))
		#globals.rewind = true
	
	#if Engine.get_physics_frames() % 60 == 0:
		#print("Curr Player Rewind History", str(rewinder.rewind_values.size()))
	
	
	# Reverse time when hit by an enemy
	#print("num of collisions: ", get_slide_collision_count())
	
	# update the survival time
	$SurvivalTime.text = "Time survived: %.1f s" % globals.survival_time
	$KillTracker.text = "Enemies killed: " + str(globals.enemies_killed)
	
	$TimeRewind.visible = globals.is_currently_rewinding
	
	if globals.is_currently_rewinding:
		return
	
	check_if_hit()
	
	
	if RewindManager.is_rewinding:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	handle_movement()
	
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
	

func check_if_hit():
	for collision in get_slide_collision_count():
		var collider = get_slide_collision(collision)
		#print(collider.get_collider().name)
		if collider != null:
			if collider.get_collider() != null:
				if collider.get_collider().has_method("shot"):
					#print("Hit by enemy")
					globals.rewind = true
					return

func handle_movement():
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
	
	if abs(velocity.x) < 0.1:
		velocity.x = 0
	if abs(velocity.y) < 0.1:
		velocity.y = 0
