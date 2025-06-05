extends CharacterBody2D

@export var speed: float = 150.0
@export var jump_velocity: float = -300.0
@export var double_jump_velocity: float = -250.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_double_jump: bool = false
@onready var sprite = $Sprite # 假设你的精灵节点名为 "Sprite"

func _physics_process(delta: float) -> void:
	# 应用重力
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# 在地面上时，重置二段跳能力 (确保只有在普通跳跃后才能二段跳)
		can_double_jump = false 

	# 处理跳跃
	if Input.is_action_just_pressed("ui_accept"): # "ui_accept" 通常是空格键
		if is_on_floor():
			velocity.y = jump_velocity
			can_double_jump = true # 离地后允许一次二段跳
		elif can_double_jump:
			velocity.y = double_jump_velocity
			can_double_jump = false # 二段跳已使用

	# 获取水平输入方向
	var direction: float = Input.get_axis("ui_left", "ui_right") # "ui_left"是左箭头/A, "ui_right"是右箭头/D

	# 处理左右移动和精灵图翻转
	if direction:
		velocity.x = direction * speed
		if sprite: # 确保精灵节点存在
			sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed) # 如果没有输入，则减速停止

	move_and_slide()
