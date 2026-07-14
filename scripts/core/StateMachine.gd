extends Node
class_name StateMachine
## Generic finite state machine. Add State child nodes (their node name is
## the state's id), set `initial_state`, and call transition_to() to switch.
## Used by both the player controller and enemy AI.

@export var initial_state: String = ""
@export var actor_path: NodePath = NodePath("..")

signal state_changed(previous: String, current: String)

var current_state: State
var current_state_name: String = ""
var _states: Dictionary = {}

func _ready() -> void:
	var actor := get_node(actor_path)
	for child in get_children():
		if child is State:
			child.actor = actor
			child.state_machine = self
			_states[child.name] = child
	if initial_state != "" and _states.has(initial_state):
		_change_state(initial_state)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func transition_to(state_name: String, msg: Dictionary = {}) -> void:
	if not _states.has(state_name):
		push_warning("StateMachine: unknown state '%s'" % state_name)
		return
	if state_name == current_state_name:
		return
	_change_state(state_name, msg)

func _change_state(state_name: String, msg: Dictionary = {}) -> void:
	var previous := current_state_name
	if current_state:
		current_state.exit()
	current_state = _states[state_name]
	current_state_name = state_name
	current_state.enter(msg)
	state_changed.emit(previous, state_name)

func is_in(state_name: String) -> bool:
	return current_state_name == state_name
