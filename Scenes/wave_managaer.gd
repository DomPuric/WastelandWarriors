extends Node

# Export variables for customization
@export var initial_wave_size : int = 5
@export var zombie_increase_per_wave : int = 2
@export var wave_interval : float = 5.0  # Time between waves in seconds
@export var zombie_scene : PackedScene  # The zombie scene to spawn

var current_wave : int = 1
var zombies_to_spawn : int = 0
var zombies_spawned : int = 0
var wave_timer : float = 0.0
var spawn_location : Vector2 = Vector2(100, 100)  # Spawn location for zombies (can be randomized)

func _ready():
	# Start first wave
	zombies_to_spawn = initial_wave_size
	start_wave()

func _process(delta: float) -> void:
	wave_timer -= delta
	if wave_timer <= 0.0 and zombies_spawned >= zombies_to_spawn:
		next_wave()

# Start a new wave
func start_wave() -> void:
	zombies_spawned = 0
	for i in range(zombies_to_spawn):
		spawn_zombie()

	# Set the timer for the next wave
	wave_timer = wave_interval

# Spawn a single zombie at a given spawn location
func spawn_zombie() -> void:
	var zombie = zombie_scene.instantiate()
	zombie.position = spawn_location  # Place zombie at the spawn location
	add_child(zombie)
	zombies_spawned += 1

# Move to the next wave
func next_wave() -> void:
	current_wave += 1
	zombies_to_spawn += zombie_increase_per_wave
	start_wave()  # Start the new wave
