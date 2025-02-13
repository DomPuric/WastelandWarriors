extends Area3D

var speed: float = 30.0
var damage: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process (delta):
	# move the bullet forwards
	global_transform.origin -= transform.basis.z.normalized() * speed * delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		destroy()


func destroy():
	queue_free()
	
	#pass # Replace with function body.
