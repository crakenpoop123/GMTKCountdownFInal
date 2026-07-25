extends Node2D

var enemy = preload("res://scenes/basic_enemy.tscn")

var spawn_dist = 750

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if globals.is_currently_rewinding:
		return
	
	if $EnemySpawnTimer.time_left == 0:
		var curr_enemy = enemy.instantiate()
		
		var spawn_angle = randf_range(-PI, PI)
		
		curr_enemy.position = get_node("../Player").global_position + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_dist
		
		#print("Spawned enemy at " + str(curr_enemy.position))
		
		get_node("./").add_child(curr_enemy)
		
		globals.total_enemies += 1
		
		$EnemySpawnTimer.start(1 / globals.enemy_spawn_rate)
