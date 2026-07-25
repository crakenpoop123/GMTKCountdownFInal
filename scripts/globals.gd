extends Node

var movement_smoothing = 4

var shoot_speed = 0.7

var enemy_spawn_rate = 1 # Enemies per second
var total_enemies = 0
var max_enemies = 50
var enemies_killed = 0

var rewind = false
var is_currently_rewinding = false
var rewind_time = 5

var survival_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
