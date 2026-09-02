extends Camera2D

var playerPosition = Vector2.ZERO

var strength = 0.0
var recovery_speed = 16.0

func _ready():
	global_position.x = -39
	global_position.y = -48

func match_player_position():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		playerPosition = player.global_position

func _process(delta):
	offset = Vector2(randf_range(-strength,strength),randf_range(-strength,strength))
	strength = move_toward(strength,0,recovery_speed * delta)
	
	match_player_position()
	if playerPosition.x > -415 and playerPosition.x < -50:
		global_position.x = lerp(playerPosition.x, global_position.x, pow(2, -7 * delta))
	if playerPosition.x < -415:
		global_position.x = lerp(-575.0, global_position.x, pow(2, -7 * delta))
	if playerPosition.x > -50:
		global_position.x = lerp(-50.0, global_position.x, pow(2, -7 * delta))

func start_timer(time_scale):
	var timer = Timer.new()
	timer.wait_time = 0.03
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()
	Engine.time_scale = time_scale

func _on_timer_timeout():
	Engine.time_scale = 1

func camera_shake_small():
	strength = 3

func camera_shake_big():
	strength = 5

func enemy_hurt():
	strength = 5
	start_timer(0.1)

func enemy_die():
	strength = 15
	start_timer(0.7)

func player_hurt():
	strength = 5
	start_timer(0.7)

func player_die():
	strength = 15
	start_timer(0.7)

func pindao():
	strength = 1
	start_timer(0.1)

func zhanhou():
	strength = 10
