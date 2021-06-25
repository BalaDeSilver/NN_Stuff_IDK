extends NN_Population

class_name Pop

# This function is necessary to set your custom agent class,
# unless you want the default agent class, which doesn't do much.
func create_agent():
	return Agente.new(4, 2, false, self)

# Godot, pls fix dis
func _init(o).(o):
	pass
