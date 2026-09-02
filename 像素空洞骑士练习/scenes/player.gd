extends CharacterBody2D

enum State { NORMAL, DASH,ATTACK,ATTACK_UP,ATTACK_DOWN,ATTACK_JUMP,
			HURT,DIE_1,DIE_2,HEAL,HEIBO,SHANGHOU,XIAZA_XVLI,XIAZA_GUOCHENG,XIAZA_LUODI,SCARED}

var currentState = State.NORMAL
var gravity = 580
var horizontalAcceleration = 2000
var maxHorizontalSpeed = 110
var jumpspeed = 280
var jumpspeed_2 = 250
var jumphigher = 4
var isStateNew = true
var maxDashSpeed = 400
var canDash = true
var canDoublejump = true
@export var isDoublejumping = false
var attack_index = 0
var hurt_direction : String

func _process(delta):
	match currentState:
		State.NORMAL:
			process_normal(delta)
		State.SCARED:
			process_scared(delta)
		State.DASH:
			process_dash(delta)
		State.ATTACK:
			process_attack(delta)
		State.ATTACK_UP:
			process_attack_up(delta)
		State.ATTACK_DOWN:
			process_attack_down(delta)
		State.ATTACK_JUMP:
			process_attack_jump(delta)
		State.HURT:
			process_hurt(delta)
		State.DIE_1:
			process_die_1(delta)
		State.DIE_2:
			process_die_2(delta)
		State.HEAL:
			process_heal(delta)
		State.HEIBO:
			process_heibo(delta)
		State.SHANGHOU:
			process_shanghou(delta)
		State.XIAZA_XVLI:
			process_xiaza_xvli(delta)
		State.XIAZA_GUOCHENG:
			process_xiaza_guocheng(delta)
		State.XIAZA_LUODI:
			process_xiaza_luodi(delta)
	isStateNew = false

func change_state(newState):
	currentState = newState
	isStateNew = true

func get_movement_vector():
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return moveVector

func update_animation():
	var moveVector = get_movement_vector()
	if !is_on_floor():
		if isDoublejumping == true:
			$AnimationPlayer.play("二段跳")
		else :
			if velocity.y < 0:
				$AnimationPlayer.play("跳跃")
			elif velocity.y > 0:
				$AnimationPlayer.play("下落")
	elif moveVector.x != 0:
		if Input.is_action_just_pressed("heal"):
			if $"/root/PlayerSoul".PlayerSoul >= 3:
				call_deferred("change_state", State.HEAL)
		$AnimationPlayer.play("移动")
	else:
		if Input.is_action_just_pressed("heal"):
			if $"/root/PlayerSoul".PlayerSoul >= 3:
				call_deferred("change_state", State.HEAL)
		$AnimationPlayer.play("站立")

func turn_direction():
	var moveVector = get_movement_vector()
	if moveVector.x != 0:
		$SpriteArea.scale.x = 1 if moveVector.x > 0 else -1
		$Hurtbox.scale.x = 1 if moveVector.x > 0 else -1
		$Attack_1.scale.x = 1 if moveVector.x > 0 else -1
		$Attack_2.scale.x = 1 if moveVector.x > 0 else -1
		$Attack_up.scale.x = 1 if moveVector.x > 0 else -1
		$Attack_down.scale.x = 1 if moveVector.x > 0 else -1
		$CollisionPolygon2D.scale.x = 1 if moveVector.x > 0 else -1

func apply_gravity_movement(delta):
	var moveVector = get_movement_vector()
	velocity.x += moveVector.x * horizontalAcceleration * delta
	velocity.x = clamp(velocity.x, -maxHorizontalSpeed, maxHorizontalSpeed)
	if moveVector.x == 0:
		velocity.x = lerp(0.0, velocity.x, pow(2, -50 * delta))
	velocity.y += gravity * delta
	move_and_slide()

func player_to_scared():
	call_deferred("change_state", State.SCARED)

func process_scared(delta):
	if isStateNew:
		var boss = get_node("/root/MainScene/enemy/Boss")
		$AnimationPlayer.play( "抬头")
		$SpriteArea.scale.x = 1 if boss.position.x > position.x else -1
		$Hurtbox.scale.x = 1 if boss.position.x > position.x else -1
		$Attack_1.scale.x = 1 if boss.position.x > position.x else -1
		$Attack_2.scale.x = 1 if boss.position.x > position.x else -1
		$Attack_up.scale.x = 1 if boss.position.x > position.x else -1
		$Attack_down.scale.x= 1 if boss.position.x > position.x else -1
		$CollisionPolygon2D.scale.x = 1 if boss.position.x > position.x else -1
		velocity.x = -200 if boss.position.x > position.x else 200
	velocity.x = lerp(0.0, velocity.x, pow(2, -10 * delta))
	velocity.y += gravity * delta
	move_and_slide()
	if !$AnimationPlayer. is_playing():
		call_deferred("change_state", State.NORMAL)

func process_normal(delta):
	var moveVector = get_movement_vector()
	velocity.x += moveVector.x * horizontalAcceleration * delta
	velocity.x = clamp(velocity.x, -maxHorizontalSpeed, maxHorizontalSpeed)
	if moveVector.x == 0:
		velocity.x = lerp(0.0, velocity.x, pow(2, -50 * delta))

	if  moveVector.y == -1:
		if is_on_floor():
			velocity.y = jumpspeed * moveVector.y
		elif canDoublejump == true:
			velocity.y = jumpspeed_2 * moveVector.y
			isDoublejumping = true
			canDoublejump = false
	if velocity.y < 0 and !Input.is_action_pressed("jump"):
		velocity.y += jumphigher * delta * gravity

	velocity.y += gravity * delta
	move_and_slide()

	update_animation()
	turn_direction()

	if is_on_floor():
		canDash = true
		canDoublejump = true
		
	if Input.is_action_just_pressed("dash") and canDash == true : 
		call_deferred("change_state", State.DASH)
	
	if Input.is_action_just_pressed("attack") and $AttackTimer.is_stopped(): 
		call_deferred("change_state", State.ATTACK)
		
	if Input.is_action_just_pressed("attack") and Input.get_action_strength("move_up"): 
		call_deferred("change_state", State.ATTACK_UP)
		
	if Input.is_action_just_pressed("attack") and Input.get_action_strength("move_down")and !is_on_floor(): 
		call_deferred("change_state", State.ATTACK_DOWN)

	if Input.is_action_just_pressed("fashu") and $"/root/PlayerSoul".PlayerSoul >=3: 
		call_deferred("change_state", State.HEIBO)

	if Input.is_action_just_pressed("fashu") and Input.get_action_strength("move_up") and $"/root/PlayerSoul".PlayerSoul >=3: 
		call_deferred("change_state", State.SHANGHOU)

	if Input.is_action_just_pressed("fashu") and Input.get_action_strength("move_down") and $"/root/PlayerSoul".PlayerSoul >=3: 
		call_deferred("change_state", State.XIAZA_XVLI)

func process_dash(delta):
	if isStateNew:
		var hasBlackDash = $BlackDash.hasBlackDash
		turn_direction()
		canDash = false
		var moveVector = get_movement_vector()
		var velocityMod = 1
		if moveVector.x != 0:
			velocityMod = sign(moveVector.x)
		else:
			velocityMod = 1 if $SpriteArea.scale.x == 1 else -1
		velocity.x = velocityMod * maxDashSpeed
		velocity.y = 0
		if hasBlackDash == true:
			if $InvincibilityTimer.is_stopped() and $xiaza_wudi.is_stopped() and $pindao_wudi2.is_stopped():
				$Hurtbox/Hurtbox.disabled = true
			$BlackDash.spawn_blackdash()
			$AnimationPlayer.play("黑冲")
		else:
			$AnimationPlayer.play("冲刺")

	velocity.x = lerp(0.0, velocity.x, pow(2, -6 * delta))
	move_and_slide()
	
	if !$AnimationPlayer.is_playing():
		if $InvincibilityTimer.is_stopped() and $xiaza_wudi.is_stopped() :
			$Hurtbox/Hurtbox.disabled = false
		call_deferred("change_state", State.NORMAL)

func process_attack(_delta):
	if isStateNew:
		turn_direction()
		if attack_index == 1:
			$AnimationPlayer.play("横劈1")
		else :
			$AnimationPlayer.play("横劈2")
	if !$AnimationPlayer.is_playing( ):
		$AttackTimer.start()
		if  attack_index == 1:
			attack_index = 0
		else:
			attack_index = 1
		call_deferred( "change_state", State.NORMAL)
	if Input.is_action_just_pressed("dash") and canDash == true : 
		call_deferred("change_state", State.DASH)
	apply_gravity_movement(_delta)

func process_attack_up(_delta):
	if isStateNew:
		turn_direction()
		$AnimationPlayer.play("上劈")
	if !$AnimationPlayer. is_playing( ):
		$AttackTimer.start()
		call_deferred("change_state", State.NORMAL)
	if Input.is_action_just_pressed("dash") and canDash == true : 
		call_deferred("change_state", State.DASH)
	apply_gravity_movement(_delta)

func process_attack_down(_delta):
	if isStateNew:
		turn_direction()
		$AnimationPlayer.play("下劈")
	if !$AnimationPlayer. is_playing():
		$AttackTimer.start()
		call_deferred("change_state", State.NORMAL)
	if Input.is_action_just_pressed("dash") and canDash == true : 
		call_deferred("change_state", State.DASH)
	apply_gravity_movement(_delta)

func process_attack_jump(_delta):
	if isStateNew:
		canDash = true
		canDoublejump = true
		velocity.x = 0
		velocity.y = -260
		$AnimationPlayer.play("下劈" )
	if velocity.y >= -130:
		call_deferred("change_state", State.NORMAL)
	if Input.is_action_just_pressed("dash") and canDash == true : 
		call_deferred("change_state", State.DASH)
	apply_gravity_movement(_delta)

func process_die_1(_delta):
	if isStateNew:
		$"/root/MainScene/GameCamera".player_die()
		$Hurtbox/Hurtbox.disabled = true
		$AnimationPlayer.play("死亡1" )
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state", State.DIE_2)

func process_die_2(_delta):
	if isStateNew:
		$AnimationPlayer.play("死亡2" )

func process_heal(_delta):
	if isStateNew:
		$AnimationPlayer.play("回血" )
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state", State.NORMAL)

func process_heibo(_delta):
	if isStateNew:
		$"/root/PlayerSoul".PlayerSoul -= 3
		$"/root/PlayerSoul".refresh_player_soul()
		turn_direction()
		velocity = Vector2.ZERO
		$AnimationPlayer.play("黑波")
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.NORMAL)

func spawn_heibo():
	$"/root/MainScene/GameCamera".camera_shake_big()
	var FashuSpawner = get_node("/root/MainScene/Player/FashuSpawner")
	if $SpriteArea.scale.x == 1:
		FashuSpawner .spawn_heibo_right()
		position.x -= 5
	else:
		FashuSpawner .spawn_heibo_left()
		position.x += 5

func process_xiaza_xvli(_delta):
	if isStateNew:
		$"/root/PlayerSoul".PlayerSoul -= 3
		$"/root/PlayerSoul".refresh_player_soul()
		velocity = Vector2.ZERO
		$AnimationPlayer.play("下砸蓄力")
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.XIAZA_GUOCHENG)

func process_xiaza_guocheng(delta):
	if isStateNew:
		$Hurtbox/Hurtbox.disabled = true
		$AnimationPlayer.play("下砸过程")
		velocity.y = 600
	velocity.y += gravity * delta
	move_and_slide()
	if is_on_floor():
		$"/root/MainScene/GameCamera".camera_shake_big()
		call_deferred("change_state",State.XIAZA_LUODI)

func process_xiaza_luodi(_delta):
	if isStateNew:
		xiaza_wudi()
		velocity = Vector2.ZERO
		$AnimationPlayer.play("下砸落地")
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",xiaza_wudi)
		call_deferred("change_state",State.NORMAL)

func xiaza_wudi():
	$xiaza_wudi.start()

func heal():
	$"/root/PlayerSoul".PlayerSoul -= 3
	$"/root/PlayerSoul".refresh_player_soul()
	$"/root/PlayerHealthBar".PlayerHealth += 5
	$"/root/PlayerHealthBar".refresh_player_health()

func process_shanghou(_delta):
	if isStateNew:
		$"/root/PlayerSoul".PlayerSoul -= 3
		$"/root/PlayerSoul".refresh_player_soul()
		turn_direction()
		velocity = Vector2.ZERO
		$AnimationPlayer.play("上吼")
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state",State.NORMAL)

func spawn_shanghou():
	$"/root/MainScene/GameCamera".camera_shake_big()
	var FashuSpawner = get_node("/root/MainScene/Player/FashuSpawner")
	FashuSpawner .spawn_shanghou()

func spawn_xiaza():
	var FashuSpawner = get_node("/root/MainScene/Player/FashuSpawner")
	FashuSpawner .spawn_xiaza()

func _on_attack_1_area_entered(area: Area2D) -> void:
	if area.name == "K_HitBoxArea":
		var pos1 = global_position
		var pos2 = area.global_position
		var effect_pos = (pos1+ pos2) / 2
		$"/root/MainScene/texiaospawner".spawn_pindao_texiao(effect_pos)
		$"/root/MainScene/GameCamera".pindao()
		call_deferred("pindao_wudi")
	else:
		$"/root/PlayerSoul".PlayerSoul += 1
		$"/root/PlayerSoul".refresh_player_soul()
		if $SpriteArea.scale.x == 1:
			global_position.x -= 5
		else:
			global_position.x += 5

func _on_attack_2_area_entered(area: Area2D) -> void:
	if area.name == "K_HitBoxArea":
		var pos1 = global_position
		var pos2 = area.global_position
		var effect_pos = (pos1+ pos2) / 2
		$"/root/MainScene/texiaospawner".spawn_pindao_texiao(effect_pos)
		$"/root/MainScene/GameCamera".pindao()
		call_deferred("pindao_wudi")
	else:
		$"/root/PlayerSoul".PlayerSoul += 1
		$"/root/PlayerSoul".refresh_player_soul()
		if $SpriteArea.scale.x == 1:
			global_position.x -= 5
		else:
			global_position.x += 5

func _on_attack_up_area_entered(area: Area2D) -> void:
	if area.name == "K_HitBoxArea":
		var pos1 = global_position
		var pos2 = area.global_position
		var effect_pos = (pos1+ pos2) / 2
		$"/root/MainScene/texiaospawner".spawn_pindao_texiao(effect_pos)
		$"/root/MainScene/GameCamera".pindao()
		call_deferred("pindao_wudi")
	else:
		$"/root/PlayerSoul".PlayerSoul += 1
		$"/root/PlayerSoul".refresh_player_soul()

func _on_attack_down_area_entered(area: Area2D) -> void:
	if area.name == "K_HitBoxArea":
		var pos1 = global_position
		var pos2 = area.global_position
		var effect_pos = (pos1+ pos2) / 2
		$"/root/MainScene/texiaospawner".spawn_pindao_texiao(effect_pos)
		$"/root/MainScene/GameCamera".pindao()
		call_deferred("pindao_wudi")
	else:
		$"/root/PlayerSoul".PlayerSoul += 1
		$"/root/PlayerSoul".refresh_player_soul()
	call_deferred("change_state", State.ATTACK_JUMP)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	$"/root/PlayerHealthBar".PlayerHealth -= 5
	$"/root/PlayerHealthBar".refresh_player_health()
	if area.global_position.x > global_position.x:
		hurt_direction = "left"
	else:
		hurt_direction = "right" 
	if $"/root/PlayerHealthBar".PlayerHealth <=0:
		call_deferred("change_state", State.DIE_1)
	else:
		call_deferred("change_state", State.HURT)

func Invincibility():
	$Hurtbox/Hurtbox.disabled = true
	$InvincibilityTimer.start()
	while true:
		$SpriteArea/Sprite2D.visible = false
		await get_tree().create_timer(0.06).timeout
		$SpriteArea/Sprite2D.visible = true
		await get_tree().create_timer(0.06).timeout
		if $InvincibilityTimer.is_stopped() and $xiaza_wudi.is_stopped() and $pindao_wudi2.is_stopped():
			$Hurtbox/Hurtbox.disabled = false
			break

func process_hurt(delta):
	if isStateNew:
		Invincibility()
		velocity.x = -150 if hurt_direction == "left" else 150
		velocity.y = -150
		$SpriteArea.scale.x = 1 if hurt_direction == "left" else -1
		$Hurtbox.scale.x = 1 if hurt_direction == "left" else -1
		$Attack_1.scale.x = 1 if hurt_direction == "left" else -1
		$Attack_2.scale.x = 1 if hurt_direction == "left" else -1
		$Attack_up.scale.x = 1 if hurt_direction == "left" else -1
		$Attack_down.scale.x = 1 if hurt_direction == "left" else -1
		$CollisionPolygon2D.scale.x = 1 if hurt_direction == "left" else -1
		$"/root/MainScene/GameCamera".player_hurt()
		$AnimationPlayer.play("受击")
	velocity.y += gravity * delta
	move_and_slide()
	if !$AnimationPlayer.is_playing():
		call_deferred("change_state", State.NORMAL)

func pindao_wudi():
	$Hurtbox/Hurtbox.disabled = true
	$pindao_wudi2.start()

func _on_xiaza_wudi_timeout() -> void:
	if $InvincibilityTimer.is_stopped() and $xiaza_wudi.is_stopped() and $pindao_wudi2.is_stopped():
		$Hurtbox/Hurtbox.disabled = false

func _on_pindao_wudi_2_timeout() -> void:
	if $InvincibilityTimer.is_stopped() and $xiaza_wudi.is_stopped() and $pindao_wudi2.is_stopped():
		$Hurtbox/Hurtbox.disabled = false
