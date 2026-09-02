extends CharacterBody2D

enum State { READY,READY_2,IDLE,HUIKAN,HUIKAN_ZHUNBEI,SHANGTIAO,SHANGTIAO_ZHUNBEI,
			MOVE,JUMP,FALL,JUMP_2,XIACHUO,XIACHUO_ZHUNBEI,XIACHUO_JIESHU,
			BACK_JUMP,BACK_FALL,BAIBO,CHONGCI_ZHUNBEI,CHONGCI,CHONGCI_TINGXIA,
			HURT,DIE_1,DIE_2,ZHANHOU_ZHUNBEI,ZHANHOU}

var currentState = State.READY
var isStateNew = true

var  playerPosition = Vector2.ZERO
var gravity = 1000
var BossHealth = 1000

func _ready() -> void:
	global_position.x = -674
	global_position.y = -200
	$HurtBoxArea.set_deferred("disabled",false)
	$BodyHitBoxArea.set_deferred("disabled",false)
	$K_HitBoxArea.set_deferred("disabled",false)

func _process(delta):
	match_player_position()
	turn_direction()
	match currentState:
		State.READY:
			process_ready(delta)
		State.READY_2:
			process_ready_2(delta)
		State.IDLE:
			process_idle(delta)
		State.HUIKAN:
			process_huikan(delta)
		State.HUIKAN_ZHUNBEI:
			process_huikan_zhunbei(delta)
		State.SHANGTIAO:
			process_shangtiao(delta)
		State.SHANGTIAO_ZHUNBEI:
			process_shangtiao_zhunbei(delta)
		State.MOVE:
			process_move(delta)
		State.JUMP:
			process_jump(delta)
		State.FALL:
			process_fall(delta)
		State.JUMP_2:
			process_jump_2(delta)
		State.XIACHUO:
			process_xiachuo(delta)
		State.XIACHUO_ZHUNBEI:
			process_xiachuo_zhunbei(delta)
		State.XIACHUO_JIESHU:
			process_xiachuo_jieshu(delta)
		State.BACK_JUMP:
			process_back_jump(delta)
		State.BACK_FALL:
			process_back_fall(delta)
		State.BAIBO:
			process_baibo(delta)
		State.CHONGCI_ZHUNBEI:
			process_chongci_zhunbei(delta)
		State.CHONGCI:
			process_chongci(delta)
		State.CHONGCI_TINGXIA:
			process_chongci_tingxia(delta)
		State.HURT:
			process_hurt(delta)
		State.DIE_1:
			process_die_1(delta)
		State.DIE_2:
			process_die_2(delta)
		State.ZHANHOU_ZHUNBEI:
			process_zhanhou_zhunbei(delta)
		State.ZHANHOU:
			process_zhanhou(delta)
	isStateNew = false

func change_state(newState):
	currentState = newState
	isStateNew = true

func turn_direction():
	if currentState in [State.CHONGCI_ZHUNBEI, State.CHONGCI, State.CHONGCI_TINGXIA]:
		return
	$SpriteArea.scale.x = 1 if playerPosition.x < global_position.x else -1
	$HurtBoxArea.scale.x = 1 if playerPosition.x < global_position.x else -1
	$BodyHitBoxArea.scale.x = 1 if playerPosition.x < global_position.x else -1
	$K_HitBoxArea.scale.x = 1 if playerPosition.x < global_position.x else -1
	$CollisionPolygon2D.scale.x = 1 if playerPosition.x < global_position.x else -1

func match_player_position():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		playerPosition = player.global_position

func process_ready(_delta):
	if isStateNew:
		turn_direction()
	$AnimationPlayer.play("站立")
	if playerPosition.x < -425:
		var door = get_node("/root/MainScene/doors/door")
		door.close()
		$fight.playing = true
		call_deferred("change_state", State.READY_2)

func process_ready_2(delta):
	if isStateNew:
		$AnimationPlayer.play("下落")
	velocity.y += gravity * delta
	move_and_slide()
	if is_on_floor():
		velocity = Vector2.ZERO
		call_deferred("change_state", State.ZHANHOU_ZHUNBEI)

func process_zhanhou_zhunbei(_delta):
	if isStateNew:
		$AnimationPlayer.play("战吼准备")
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state", State.ZHANHOU)

func process_zhanhou(_delta):
	if isStateNew:
		$"/root/MainScene/GameCamera".zhanhou()
		var boss_pos = position
		boss_pos.y -= 12
		$"/root/MainScene/texiaospawner".spawn_zhanhou_texiao(boss_pos)
		var player = get_node("/root/MainScene/Player/Player")
		player.player_to_scared()
		$AnimationPlayer.play("战吼")
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state", State.IDLE)

func open_door():
	var door = get_node("/root/MainScene/doors/door")
	door.open()

func process_idle(delta):
	turn_direction()
	if isStateNew:
		$AnimationPlayer.play("站立")
	velocity.y += gravity * delta
	move_and_slide()
	if !$AnimationPlayer.is_playing():
		if randf() < 0.3:   #randf()会生成大于0,小于1的浮点数
			if abs(playerPosition.x - global_position.x) < 80:
				call_deferred("change_state", State.HUIKAN_ZHUNBEI)
			else:
				if randf() > 0.5:
					call_deferred("change_state", State.MOVE)
				else:
					call_deferred("change_state", State.JUMP)
		else:
			if randf() > 0.5:
				call_deferred("change_state", State.JUMP_2)
			else:
				call_deferred("change_state", State.BACK_JUMP)

func process_huikan(delta):
	if isStateNew:
		velocity.x = -300 if $SpriteArea.scale.x == 1 else 300
		velocity.y = 0
		$AnimationPlayer.play("挥砍")
	velocity.y += gravity * delta
	move_and_slide()
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.SHANGTIAO_ZHUNBEI)

func process_huikan_zhunbei(delta):
	if isStateNew:
		velocity = Vector2.ZERO
		$AnimationPlayer.play("挥砍准备")
	velocity.y += gravity * delta
	move_and_slide()
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.HUIKAN)

func process_shangtiao(delta):
	if isStateNew:
		velocity.x = -80 if $SpriteArea.scale.x == 1 else 80
		velocity.y = -400
		$AnimationPlayer.play("上挑")
	velocity.y += gravity * delta
	move_and_slide()
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.FALL)

func process_shangtiao_zhunbei(delta):
	if isStateNew:
		velocity = Vector2.ZERO
		$AnimationPlayer.play("上挑准备")
	velocity.y += gravity * delta
	move_and_slide()
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.SHANGTIAO)

func process_move(delta):
	turn_direction()
	if isStateNew:
		if playerPosition.x > global_position.x:
			velocity.x = 80
		else:
			velocity.x = -80
		velocity.y = 0
		$AnimationPlayer.play("移动")
	velocity.y += gravity * delta
	move_and_slide()
	if abs(playerPosition.x - global_position.x) < 80:
		call_deferred("change_state",State.HUIKAN_ZHUNBEI)

func process_jump(delta):
	if isStateNew:
		velocity.x = playerPosition.x - global_position.x 
		velocity.y = -400
		$AnimationPlayer.play("跳跃")
	velocity.y += gravity * delta
	move_and_slide()
	if velocity.y > 0:
		call_deferred("change_state",State.FALL)

func process_fall(delta):
	if isStateNew:
		$AnimationPlayer.play("下落")
	velocity.y += gravity * delta
	move_and_slide()
	if is_on_floor():
		velocity = Vector2.ZERO
		call_deferred("change_state",State.IDLE)

func process_jump_2(delta):
	if isStateNew:
		velocity.x = (playerPosition.x - global_position.x)*2
		velocity.y = -400
		$AnimationPlayer.play("跳跃")
	velocity.y += gravity * delta
	move_and_slide()
	if velocity.y > 0:
		call_deferred("change_state",State.XIACHUO_ZHUNBEI)

func process_xiachuo_zhunbei(_delta):
	if isStateNew:
		velocity = Vector2.ZERO
		$AnimationPlayer.play("下戳准备")
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.XIACHUO)

func process_xiachuo(delta):
	if isStateNew:
		velocity.y += 100
		$AnimationPlayer.play("下戳")
	velocity.y += gravity * delta
	move_and_slide()
	if is_on_floor():
		$"/root/MainScene/GameCamera".camera_shake_small()
		var guci_spawner = get_node("/root/MainScene/enemy/guci_spawner")
		guci_spawner.spawn_guci()
		call_deferred("change_state",State.XIACHUO_JIESHU)

func process_xiachuo_jieshu(_delta):
	if isStateNew:
		velocity = Vector2.ZERO
		$AnimationPlayer.play("下戳结束")
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.IDLE)

func process_back_jump(delta):
	if isStateNew:
		velocity.x =  -740 - global_position.x if playerPosition.x > -573 else -415 - global_position.x
		velocity.y = -400
		if velocity.x < 0 and $SpriteArea.scale.x == 1:
			$AnimationPlayer.play("跳跃")
		if velocity.x < 0 and $SpriteArea.scale.x == -1:
			$AnimationPlayer.play("后跳")
		if velocity.x > 0 and $SpriteArea.scale.x == 1:
			$AnimationPlayer.play("后跳")
		if velocity.x > 0 and $SpriteArea.scale.x == -1:
			$AnimationPlayer.play("跳跃")
	velocity.y += gravity * delta
	move_and_slide()
	if velocity.y > 0:
		call_deferred("change_state",State.BACK_FALL)

func process_back_fall(delta):
	if isStateNew:
		if velocity.x < 0 and $SpriteArea.scale.x == 1:
			$AnimationPlayer.play("下落")
		if velocity.x < 0 and $SpriteArea.scale.x == -1:
			$AnimationPlayer.play("后跳下落")
		if velocity.x > 0 and $SpriteArea.scale.x == 1:
			$AnimationPlayer.play("后跳下落")
		if velocity.x > 0 and $SpriteArea.scale.x == -1:
			$AnimationPlayer.play("下戳")
	velocity.y += gravity * delta
	move_and_slide()
	if is_on_floor():
		velocity = Vector2.ZERO
		if randf()>0.5:
			call_deferred("change_state",State.BAIBO)
		else:
			call_deferred("change_state",State.CHONGCI_ZHUNBEI)

func process_baibo(_delta):
	if isStateNew:
		turn_direction()
		velocity = Vector2.ZERO
		$AnimationPlayer.play("白波")
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.IDLE)

func spawn_baibo():
	$"/root/MainScene/GameCamera".camera_shake_small()
	var baibo_spawner = get_node("/root/MainScene/enemy/baibospawner")
	if $SpriteArea.scale.x == 1:
		baibo_spawner .spawn_baibo_left()
		position.x += 5
	else:
		baibo_spawner .spawn_baibo_right()
		position.x -= 5

func process_chongci_zhunbei(_delta):
	if isStateNew:
		turn_direction()
		velocity = Vector2.ZERO
		$AnimationPlayer.play("冲刺准备")
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.CHONGCI)

func process_chongci(delta):
	if isStateNew:
		$"/root/MainScene/GameCamera".camera_shake_small()
		velocity.x = -400 if $SpriteArea.scale.x == 1 else 400
		velocity.y = 0
		$AnimationPlayer.play("冲刺")
	velocity.y += gravity * delta
	move_and_slide()
	if global_position.x < -725:
		call_deferred("change_state",State.CHONGCI_TINGXIA)
	if global_position.x > -425:
		call_deferred("change_state",State.CHONGCI_TINGXIA)

func process_chongci_tingxia(delta):
	if isStateNew:
		velocity.x = lerp(0.0,velocity.x,pow(2,-10 * delta))
		$AnimationPlayer.play("冲刺停下")
	velocity.y += gravity * delta
	move_and_slide()
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.IDLE)

func process_hurt(delta):
	if isStateNew:
		$"/root/MainScene/GameCamera".enemy_hurt()
		turn_direction()
		$AnimationPlayer.play("僵直")
		velocity.x = 400 if $SpriteArea.scale.x == 1 else -400
	velocity.x= lerp(0.0, velocity.x, pow(2, -10*delta))
	velocity.y += gravity * delta
	move_and_slide()
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.IDLE)

func process_die_1(delta):
	if isStateNew:
		$"/root/MainScene/GameCamera".enemy_hurt()
		$HurtBoxArea/HurtBox.set_deferred("disabled",true)
		$BodyHitBoxArea/BodyHitBox.set_deferred("disabled",true)
		$K_HitBoxArea/K_HitBox.set_deferred("disabled",true)
		turn_direction()
		$AnimationPlayer.play("僵直")
		velocity.x = 400 if $SpriteArea.scale.x == 1 else -400
	velocity.x= lerp(0.0, velocity.x, pow(2, -10*delta))
	velocity.y += gravity * delta
	move_and_slide()
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.DIE_2)

func process_die_2(_delta):
	if isStateNew:
		$AnimationPlayer.play("死亡")

func enemy_die_camera_shake():
	$"/root/MainScene/GameCamera".enemy_die()

var hurt_thresholds = [750, 500, 250]   # 三个触发点
var triggered_thresholds = []            # 记录已经触发过的阈值

func _on_hurt_box_area_area_entered(area: Area2D) -> void:
	# 如果已经死亡或处于僵直状态，我们仍然允许扣血，但不触发新的僵直（但扣血逻辑在下面）
	# 所以这里不再提前 return，允许扣血继续
	$MaterialTimer.start()
	$SpriteArea/Sprite2D.use_parent_material = false
	$hurt.playing = true
	var boss_pos = position
	$"/root/MainScene/texiaospawner".spawn_hit_particle(boss_pos)
	# 统一计算伤害（避免重复扣血）
	var damage = 0
	match area.name:
		"Attack_1", "Attack_2", "Attack_UP", "Attack_DOWN":
			damage = 13
		"Heibobox":
			damage = 30
		"shanghoubox":
			damage = 20
		"xiazabox", "xiazabox2":
			damage = 30
		_:
			return  # 未知攻击，忽略
	BossHealth -= damage
	print("剩余血量：", BossHealth)
	# 检查是否应触发僵直（血量低于阈值且该阈值未被触发）
	var should_hurt = false
	for threshold in hurt_thresholds:
		if BossHealth < threshold and not (threshold in triggered_thresholds):
			triggered_thresholds.append(threshold)
			should_hurt = true
			break  # 每次只触发一个阈值
	if should_hurt:
		call_deferred("change_state", State.HURT)
	elif BossHealth <= 0:
		call_deferred("change_state", State.DIE_1)

func _on_material_timer_timeout() -> void:
	$SpriteArea/Sprite2D.use_parent_material = true
