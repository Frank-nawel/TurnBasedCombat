class_name BattleActionState
extends StateMachineState

var player: Player
var body: CharacterBody2D
var anim: AnimationPlayer
var sprite: AnimatedSprite2D
var attack_finished: bool = false


func _enter_state() -> void:
	var sm_parent := get_state_machine().get_parent()
	player = sm_parent.get_node_or_null("Player") as Player
	assert(player != null, "%s: no se encontró nodo Player" % name)
	anim   = sm_parent.get_node("AnimationPlayer")
	sprite = sm_parent.get_node("AnimatedSprite2D")
	body   = sm_parent as CharacterBody2D


# _exit_state NO desconecta animation_finished.
# AttackState._enter_state() desconecta y reconecta limpiamente cada vez,
# lo que evita que el cambio de estado al mismo nodo (step 1 → step 2)
# rompa la señal antes de que la nueva animación empiece.
func _exit_state() -> void:
	pass


func _process(_delta: float) -> void:
	if sprite and player:
		sprite.flip_h = player.last_facing_flip_h


func _start_action() -> void:
	attack_finished = false
	if anim and not anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)
	_play_attack_animation()


func _play_attack_animation() -> void:
	pass


func _on_animation_finished(_anim_name: String) -> void:
	pass


func _play_once(animation_name: String) -> void:
	if not anim or not sprite or attack_finished:
		return
	attack_finished = true
	sprite.flip_h = player.last_facing_flip_h
	if anim.has_animation(animation_name):
		anim.get_animation(animation_name).loop_mode = Animation.LOOP_NONE
	anim.play(animation_name)
	anim.seek(0.0)


func _return_to_next_state() -> void:
	var move_state := get_state_machine().get_node("MoveState") as MoveState
	if move_state and move_state.move_action:
		if not move_state.move_action.value_axis_2d.is_zero_approx():
			get_state_machine().current_state = move_state
			return
	get_state_machine().current_state = get_state_machine().get_node("IdleState")
