extends Camera2D

export var clamp_x = 0
export var clamp_y = 0


func _process(_delta):
	self.set_offset(Vector2(get_parent().position.x -320, get_parent().position.y -240))
	self.offset.x = clamp(offset.x, 0, clamp_x) #320 or 640
	self.offset.y = clamp(offset.y, 0, clamp_y) #240 or 480
	pass

