extends CanvasLayer

var PlayerSoul = 9

func _ready():
	PlayerSoul = 9
	
func refresh_player_soul():
	# 确保数值在有效范围内 (0-9)
	PlayerSoul = clamp(PlayerSoul, 0, 9)
	# 使用 match 语句替代多个 if
	match PlayerSoul:
		0:
			$AnimationPlayer.play("0")
		1:
			$AnimationPlayer.play("1")
		2:
			$AnimationPlayer.play("2")
		3:
			$AnimationPlayer.play("3")
		4:
			$AnimationPlayer.play("4")
		5:
			$AnimationPlayer.play("5")
		6:
			$AnimationPlayer.play("6")
		7:
			$AnimationPlayer.play("7")
		8:
			$AnimationPlayer.play("8")
		9:
			$AnimationPlayer.play("9")
