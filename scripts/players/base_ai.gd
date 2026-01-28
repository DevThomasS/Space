class_name BaseAI extends BasePlayer

var _think_timer := 0.0

func _process(delta):
	_think_timer += delta
	if _think_timer >= data.think_interval:
		_think_timer = 0.0
		think()

func think():
	# Overridden in subclasses
	push_error("BaseAI.think() not implemented")
