extends CharacterBody2D

#=============================================================================
# 导出变量 (可以在 Godot 编辑器中调整)
#=============================================================================

# --- 移动 ---
@export var speed: float = 150.0
# --- 跳跃 ---
@export var jump_velocity: float = -300.0
@export var double_jump_velocity: float = -250.0
@export var stomp_bounce_velocity: float = -150.0 # 踩到敌人后的反弹力
# --- 爬墙与墙跳 ---
@export var wall_slide_gravity: float = 80.0 # 滑墙时的重力，比正常重力小
@export var wall_jump_push_force: float = 200.0 # 墙跳时的水平推力
# --- 冲刺 ---
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.15 # 冲刺持续时间

#=============================================================================
# 内部变量
#=============================================================================
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_double_jump: bool = false
var can_dash: bool = true
var is_dashing: bool = false

#=============================================================================
# 节点引用 (使用 @onready 确保节点已准备好)
#=============================================================================
@onready var sprite: Sprite2D = $Sprite2D # 确保你的精灵节点叫 "Sprite2D"
@onready var dash_timer: Timer = $DashTimer # 需要在Player下添加一个Timer节点
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer # 需要添加另一个Timer

#=============================================================================
# Godot 核心函数
#=============================================================================

func _ready() -> void:
	# 连接冲刺计时器的信号
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timer_timeout)

func _physics_process(delta: float) -> void:
	# 如果正在冲刺，则不处理其他逻辑
	if is_dashing:
		move_and_slide()
		return

	# --- 重力应用 ---
	# 不在地面上时应用重力
	if not is_on_floor():
		# 如果正在滑墙，则使用较小的滑墙重力
		if is_on_wall() and velocity.y > 0:
			velocity.y = wall_slide_gravity
		else:
			velocity.y += gravity * delta
	else:
		# 在地面上时，重置二段跳和冲刺能力
		can_double_jump = false
		can_dash = true

	# --- 输入处理 ---
	var input_direction: float = Input.get_axis("ui_left", "ui_right")
	
	# --- 跳跃 & 墙跳 ---
	if Input.is_action_just_pressed("ui_accept"): # 'ui_accept' 通常是空格键
		if is_on_floor():
			# 普通跳跃
			velocity.y = jump_velocity
			can_double_jump = true
		elif is_on_wall():
			# 墙跳
			# 获取墙体的法线向量 (指向远离墙壁的方向)
			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * wall_jump_push_force
			velocity.y = jump_velocity
			can_double_jump = true # 墙跳后允许二段跳
		elif can_double_jump:
			# 二段跳
			velocity.y = double_jump_velocity
			can_double_jump = false

	# --- 冲刺 ---
	if Input.is_action_just_pressed("dash") and can_dash:
		perform_dash()

	# --- 左右移动 ---
	if input_direction:
		velocity.x = input_direction * speed
		sprite.flip_h = input_direction < 0 # 翻转精灵
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# 执行移动
	move_and_slide()
	
	# --- 踩踏攻击检测 ---
	check_stomp()


#=============================================================================
# 自定义函数
#=============================================================================

# 执行冲刺的函数
func perform_dash() -> void:
	is_dashing = true
	can_dash = false
	
	# 根据精灵朝向确定冲刺方向
	var dash_direction = -1.0 if sprite.flip_h else 1.0
	velocity.x = dash_direction * dash_speed
	velocity.y = 0 # 保持水平冲刺
	
	dash_timer.start(dash_duration)
	dash_cooldown_timer.start()

# 冲刺持续时间结束
func _on_dash_timer_timeout() -> void:
	is_dashing = false
	# 冲刺结束后给一个小的速度，避免突然停止
	velocity.x = move_toward(velocity.x, 0, dash_speed)

# 冲刺冷却结束
func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

# 检测踩踏
func check_stomp() -> void:
	# 只有在下落时才能触发踩踏
	if velocity.y <= 0:
		return

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		# 检查是否碰到了敌人 (假设敌人都在 "enemies" 组里)
		if collision.get_collider().is_in_group("enemies"):
			# 检查碰撞法线，确保是从上方碰撞
			if collision.get_normal().dot(Vector2.UP) > 0.5:
				var enemy = collision.get_collider()
				# 调用敌人的被踩踏函数
				if enemy.has_method("on_stomped"):
					enemy.on_stomped()
				# 自身向上反弹
				velocity.y = stomp_bounce_velocity
				print("Stomped on an enemy!")
