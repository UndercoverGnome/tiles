extends CharacterBody2D


const SPEED = 250
const FRICTION = 0.9

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	velocity += Vector2(Input.get_axis("ui_left", "ui_right")* SPEED*10*delta,Input.get_axis("ui_up", "ui_down")* SPEED*10*delta)
	velocity *= FRICTION

	move_and_slide()
