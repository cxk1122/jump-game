extends AnimatableBody2D

# 导出变量
@export var move_speed: float = 60.0 # 平台移动速度 (像素/秒)
@export var target_node_path: NodePath # 在编辑器中指定目标点的路径

# 内部变量
var start_position: Vector2
var target_position: Vector2

func _ready() -> void:
	# 检查目标点是否存在
	var target_node = get_node_or_null(target_node_path)
	if not target_node:
		print("Error: Moving platform could not find target node at path: ", target_node_path)
		return

	start_position = global_position
	target_position = target_node.global_position

	# 创建并配置一个 Tween (补间动画) 来移动平台
	create_tween_animation()

func create_tween_animation() -> void:
	# 计算从起点到终点所需的时间
	var duration = start_position.distance_to(target_position) / move_speed
	
	# 创建一个新的 Tween
	var tween = create_tween()
	# 设置为无限循环
	tween.set_loops()
	# 设置过渡类型为平滑的 SINE 曲线
	tween.set_trans(Tween.TRANS_SINE)

	# 添加移动动画：从起点到终点，再从终点回到起点
	tween.tween_property(self, "global_position", target_position, duration)
	tween.tween_property(self, "global_position", start_position, duration)
