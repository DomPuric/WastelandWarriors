extends CharacterBody3D

signal health_changed(health)

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var raycast = $Camera3D/RayCast3D
@onready var Lose = get_parent().get_node("CanvasLayer/Lose")



@onready var world = get_node("/root/testWorld")

var hit_cooldown := 0.3  # cooldown time in seconds between hits
var time_since_last_hit := 0.0

var health = 100

var SPEED = 5.0
var JUMP_VELOCITY

var max_stamina = 100 
var stamina = 100
var stamina_drain = 20.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

	Global.instakill = 1

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		if Global.aiming == true:
			rotate_y(-event.relative.x * .0005)
			camera.rotate_x(-event.relative.y * .0005)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
			
		else:
			rotate_y(-event.relative.x * .005)
			camera.rotate_x(-event.relative.y * .005)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):

	if Input.is_action_pressed("player_run") and stamina > 0:
		SPEED = 10.0
		stamina -= stamina_drain * delta
	else:
		SPEED = 5.0
		if stamina < max_stamina:
			stamina += stamina_drain * delta 
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

		
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
	time_since_last_hit += delta
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
	
		if collider and time_since_last_hit >= hit_cooldown:
			if collider.name.begins_with("Enemy"):
				reduce_health(7)
				time_since_last_hit = 0.0
		elif collider.name.begins_with("Fast"):
			reduce_health(7)
			time_since_last_hit = 0.0
		elif collider.name.begins_with("Brute"):
			reduce_health(15)
			time_since_last_hit = 0.0

func restore_health_to_max():
	health = 100
	health_changed.emit(health)
	
func insta_kill():
	Global.instakill = 100
	
	var timer = Timer.new()
	timer.wait_time = 20
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_insta_kill_timeout"))
	add_child(timer)
	timer.start()
	
func _on_insta_kill_timeout():
	Global.instakill = 1

func reduce_health(amount):
	health -= amount
	world.update_health_bar(health)
	if health <= 0:
		Lose.show()
