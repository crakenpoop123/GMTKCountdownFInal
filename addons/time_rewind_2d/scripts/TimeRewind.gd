@icon("res://addons/time_rewind_2d/essentials/icon.svg")

#TODO: Add a menu in project settings for default rewind time on script.

# Script responsible for handling time manipulation for a 2D body
extends Node2D
class_name TimeRewind2D

# Nodes group
@export_subgroup("Nodes")
@export var body: Node2D ## The main body of the object to be manipulated
@export var collision_shape: CollisionShape2D ## The collision shape of the object

# Settings group
@export_subgroup("Settings")
@export_range(1, 10, 1, "suffix:sec") var rewind_time: float = 3 ## Duration of time that can be rewound, in seconds

@export var rewindable_properties: Array[String] ## Properties that will be rewound

# On ready variables initialized when the script is ready
@onready var max_values_stored
@onready var rewind_manager: RewindManager = RewindManager ## Reference to the rewind manager

# Internal variables for managing the rewind process
var rewind_values: Dictionary = {} ## Dictionary to store rewind values for properties
var rewind_variables: Dictionary = {
	"survival_time": globals.survival_time,
	"enemies_killed": globals.enemies_killed
}

# Initialization function
func _ready() -> void:
	max_values_stored = rewind_time * Engine.physics_ticks_per_second ## Maximum number of values to store for rewind
	#print("Max Values Stored: ", max_values_stored)
	if not body:
		push_error("TimeRewind2D: 'body' is not assigned.")
		return
		
	if rewind_time <= 0:
		push_error("TimeRewind2D: 'rewind_time' must be greater than 0.")
		return
	
	if not collision_shape:
		push_warning("TimeRewind2D: 'collision_shape' is not assigned.")

	if rewindable_properties.is_empty():
		push_warning("TimeRewind2D: 'rewindable_properties' is empty. No properties will be rewound.")
		
	for property in rewindable_properties:
		if get_nested_property(body, property) == null:
			push_error("TimeRewind2D: Property '" + property + "' does not exist on the body.")
		# Initialize lists for each rewindable property
		rewind_values[property] = []
		
	for property in rewind_variables:
		#print(property)
		#if get_nested_property(body, property) == null:
			#push_error("TimeRewind2D: Property '" + property + "' does not exist on the body.")
		# Initialize lists for each rewindable variable
		rewind_values[property] = []

	# Connect rewind start signal
	rewind_manager.connect("rewind_stopped", _on_rewind_stopped)
	rewind_manager.connect("rewind_started", _on_rewind_started)

# Called every physics frame
func _physics_process(delta: float) -> void:
	if not rewind_manager.is_rewinding:
		# Store current property values when not rewinding
		_store_current_values()
	else:
		# Rewind properties when rewinding
		_rewind_process(delta)

# Stores the current values of the rewindable properties
func _store_current_values() -> void:
	#print(body.name, " max limit: ", max_values_stored, " | current count: ", rewind_values[rewindable_properties[0]].size())
	
	if rewindable_properties.is_empty():
		return

	# Remove the oldest values if the max limit is reached	
	if rewind_values[rewindable_properties[0]].size() >= max_values_stored:
		for key in rewind_values.keys():
			rewind_values[key].pop_front()
		#print("frames in RewindManager.gd", str(rewind_values[rewindable_properties[0]].size()))

	# Store the current value of the property
	for property in rewindable_properties:
		#print(property)
		var value = get_nested_property(body, property)
		if value == null:
			print("Rewindable Property Value == null")
			return
		rewind_values[property].append(value)
		#if Engine.get_physics_frames() % 60 == 0:
			#print("appending frame at size: ", rewind_values[rewindable_properties[0]].size())
	
	rewind_variables = {
		"survival_time": globals.survival_time,
		"enemies_killed": globals.enemies_killed
	}
	
	for key in rewind_variables:
		var value = rewind_variables[key]
		if value == null:
			print("Rewindable Property Value == null")
			return
		rewind_values[key].append(value)
	

# Rewinds the properties to previous values
func _rewind_process(delta: float) -> void:
	#print(body.name, "'s frames remaining in _rewind_process: ", rewind_values[rewindable_properties[0]].size())
	
	if rewindable_properties.is_empty():
		return
	
	#print("survival time array: ", (rewind_values["globals.survival_time"]))
	
	# Speed it up to rewind_speed
	for i in range(RewindManager.rewind_speed):
		# Stop rewind if there are no values left
		if rewind_values[rewindable_properties[0]].is_empty():
			return

		# Set the property to a previous value
		for property in rewindable_properties:
			if rewind_values[property].is_empty():
				push_warning("TimeRewind2D: No more values to rewind for property '" + property + "'.")
				continue
			var value = rewind_values[property].pop_back()
			set_nested_property(body, property, value)
		
		# Set the variables to a previous value
		for property in rewind_variables:
			if rewind_values[property].is_empty():
				push_warning("TimeRewind2D: No more values to rewind for property '" + property + "'.")
				continue
			var value = rewind_values[property].pop_back()
			#print("Setting ", property, " to ", value)
			globals.set(property, value)

# Called when rewind starts
func _on_rewind_started():
	 # Disable collision during rewind
	if collision_shape:
		collision_shape.set_disabled.call_deferred(true)
	else:
		push_error("TimeRewind2D: 'collision_shape' is not valid when starting rewind.")
	
# Called when rewind stops
func _on_rewind_stopped():
	# Re-enable collision after rewind
	if collision_shape:
		collision_shape.set_disabled.call_deferred(false)
	else:
		push_error("TimeRewind2D: 'collision_shape' is not valid when stopping rewind.")

# Helper function to get a nested property from an object
func get_nested_property(root: Object, path: String) -> Variant:
	var current = root
	var properties = path.split(".")
	for property in properties:
		if not current:
			push_error("TimeRewind2D: Failed to retrieve property '" + path + "'.")
			return null
		current = current.get(property)
	return current

# Helper function to set a nested property in an object
func set_nested_property(root: Object, path: String, value: Variant) -> void:
	var current = root
	var properties = path.split(".")
	for i in range(properties.size() - 1):
		if not current:
			push_error("TimeRewind2D: Failed to set property '" + path + "'.")
			return
		current = current.get(properties[i])
	current.set(properties[-1], value)
