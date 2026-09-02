extends CharacterBody2D

@onready var move_state_machine: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var tool_state_machine: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/ToolStateMachine/playback")
var direction:Vector2
var last_direction : Vector2
var speed:=200
var can_move = true
var tool_direction_offset := 14
var tool_y_offset := 4
enum Tools{HOE,AXE,WATER}

var current_tool:Tools = Tools.AXE
const tool_connection={
	Tools.HOE:"hoe",
	Tools.AXE:"axe",
	Tools.WATER:"water",
}

var current_seed:Global.Seeds = Global.Seeds.CORN
signal tool_use(tool:Tools,pos:Vector2)
signal seed_use(seed:Global.Seeds,pos:Vector2)

func _physics_process(_delta: float) -> void:
	if can_move:
		get_input()
	if direction:
		last_direction = direction
		if not $Sound/Walksound/Timer.time_left:
			$Sound/Walksound/Timer.start()
	else:
		$Sound/Walksound/Timer.stop()
	velocity = direction * speed * int(can_move)
	move_and_slide()
	animation()
	
func get_input():
	direction = Input.get_vector("left","right","up","down")
	
	if Input.is_action_just_pressed("action"):
		tool_state_machine.travel(tool_connection[current_tool])
		$AnimationTree.set("parameters/OneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		can_move=false
		if current_tool in [Tools.HOE,Tools.WATER]:
			await $AnimationTree.animation_finished
			tool_use.emit(current_tool,position + last_direction * tool_direction_offset + Vector2(0,tool_y_offset))
			if current_tool == Tools.HOE:
				$Sound/Hoesound.play()
			else:
				$Sound/Watersound.play()

	if Input.is_action_just_pressed("tool_forward") or Input.is_action_just_pressed("tool_backward"):
		var tool_direction = Input.get_axis("tool_backward","tool_forward") as int
		current_tool = posmod(current_tool + tool_direction,Tools.size()) as Tools
		print(current_tool)
		
	if Input.is_action_just_pressed("seed_toggle"):
		current_seed = posmod(current_seed + 1,Global.Seeds.size()) as Global.Seeds
		print(current_seed)
	if Input.is_action_just_pressed("plant"):
		can_move=false
		direction=Vector2.ZERO
		seed_use.emit(current_seed,position + last_direction * tool_direction_offset + Vector2(0,tool_y_offset))
		await get_tree().create_timer(0.5).timeout
		can_move=true
	
func animation():
	if direction:
		move_state_machine.travel("move")
		var target_vector:Vector2 = Vector2(round(direction.x),round(direction.y))
		$AnimationTree.set("parameters/MoveStateMachine/idle/blend_position",target_vector)
		$AnimationTree.set("parameters/MoveStateMachine/move/blend_position",target_vector)
		for state in tool_connection.values():
			$AnimationTree.set("parameters/ToolStateMachine/"+ state + "/blend_position",target_vector)
	else:
		move_state_machine.travel("idle")

func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	can_move = true

func axe_use():
	tool_use.emit(current_tool,position + last_direction * tool_direction_offset + Vector2(0,tool_y_offset))
	$Sound/Axesound.play()

func _on_timer_timeout() -> void:
	$Sound/Walksound.play()
