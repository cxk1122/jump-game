extends CharacterBody2D

@export var speed: float = 30.0
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: Sprite2D = $Sprite2D
@onready var floor_detector: RayCast2D = $FloorDetector
@onready var edge_detector: RayCast2D = $EdgeDetector

var direction: int = -1 # -1 for left, 1 for right

func _physics_process(delta: float) -> void:
	# 应用重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 检查是否需要转身
	if is_on_floor():
		if floor_detector.is_colliding() or not edge_detector.is_colliding():
			turn_around()

	# 设置水平速度
	velocity.x = direction * speed
	
	# 翻转精灵图
	sprite.flip_h = (direction == 1)
	
	move_and_slide()

func turn_around() -> void:
	direction *= -1

# 这个函数将被玩家的踩踏逻辑调用
func on_stomped() -> void:
	print("Slime was stomped!")
	# 在这里可以添加死亡动画或粒子效果
	# ...
	# 禁用碰撞，防止再次被检测
	$CollisionShape2D.set_deferred("disabled", true)
	# 播放简单的消失动画
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.3) # 0.3秒内渐变消失
	await tween.finished # 等待动画完成
	queue_free() # 从场景中移除
