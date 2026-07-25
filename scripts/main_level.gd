extends Node2D

var is_auto_rewinding = false
var rewind_time = 5
var rewind_countdown = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Get rid of enemies if there are too many
	if globals.total_enemies > globals.max_enemies:
		for Enemy in get_node("./Enemies").get_children():
			if Enemy.has_method("shot") and globals.total_enemies > globals.max_enemies:
				Enemy.queue_free()
				globals.total_enemies -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_auto_rewinding:
		globals.survival_time += delta
	
	if globals.rewind == true:
		globals.rewind = false
		if not is_auto_rewinding:
			rewind_countdown = rewind_time
			is_auto_rewinding = true
			globals.is_currently_rewinding = true
			
			RewindManager.start_rewind()
	
	if is_auto_rewinding:
		rewind_countdown -= delta * RewindManager.rewind_speed
		globals.survival_time -= delta * RewindManager.rewind_speed
		globals.survival_time = max(0.0, globals.survival_time)
		if rewind_countdown <= 0:
			is_auto_rewinding = false
			globals.is_currently_rewinding = false
			RewindManager.stop_rewind()
			
