extends Area2D

var direction:Vector2
var speed := 200

#子弹变形
func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D,"scale",Vector2.ONE,0.5).from(Vector2.ZERO)
	$AudioStreamPlayer2D.play()

#按瞄准方向发射
func setup(pos:Vector2, dir:Vector2):
	position = pos + dir * 16
	direction = dir
func _physics_process(delta:float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if "hit" in body :
		body.hit()
	queue_free()


	
