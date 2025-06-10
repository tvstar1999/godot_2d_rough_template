extends Line2D


func _ready():
	for i in points.size() - 1:
		var new_shape = CollisionShape2D.new()
		$collision.add_child(new_shape)
		var segment = SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		new_shape.shape = segment

