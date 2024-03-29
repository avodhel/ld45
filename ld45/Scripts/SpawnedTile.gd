extends "res://Scripts/Tile.gd"

#warning-ignore:unused_class_variable
onready var move_timer = $move_timer

func _on_move_timer_timeout():
	move()

func move():
	# Calculate the direction the spawned object is trying to go
	var dir = Vector2(0, 0)
	
	dir = Vector2(0, 1)
	
	# Move the spawned object to the new position
	if (dir != Vector2(0, 0)):
		var target = Vector2(grid_x + dir[0], grid_y + dir[1])
		self.position = grid_to_pixel(target[0], target[1])
		grid_x = target[0]
		grid_y = target[1]

func _on_visibility_screen_exited():
	call_deferred("free")
