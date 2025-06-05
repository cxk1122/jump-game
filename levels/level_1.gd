extends Node2D

# 假设你在场景中已经放置了Player的实例，并且它被命名为 "PlayerInstance"
# 如果是动态生成的，则需要在_ready中获取实例
@onready var player_instance = $PlayerInstance 
@onready var player_start_marker = $PlayerStart # 假设你有一个Marker2D节点叫 "PlayerStart"
@onready var light_shards_container = $LightShards # 假设所有光之碎片实例都在这个节点下
@onready var game_ui_instance = $GameUI/UIInstance # 假设UI实例的路径是这样

var shards_total_in_level: int = 0
var shards_collected_count: int = 0

func _ready() -> void:
	# 设置玩家初始位置
	if player_instance and player_start_marker:
		player_instance.global_position = player_start_marker.global_position

	# 统计关卡中的碎片总数并连接信号
	if light_shards_container:
		shards_total_in_level = light_shards_container.get_child_count()
		for shard in light_shards_container.get_children():
			# 确保shard是LightShard类型并且有shard_collected信号
			if shard.has_signal("shard_collected"):
				shard.shard_collected.connect(_on_a_shard_was_collected)
	
	_update_ui()
	print("Level ready. Total shards: ", shards_total_in_level)

func _on_a_shard_was_collected() -> void:
	shards_collected_count += 1
	print("Collected a shard! Total collected: ", shards_collected_count)
	_update_ui()

	# 可在此添加逻辑，例如检查是否所有碎片都被收集
	if shards_collected_count >= shards_total_in_level:
		print("All shards collected! Level complete!")
		# 触发关卡完成事件，例如加载下一关卡

func _update_ui() -> void:
	if game_ui_instance and game_ui_instance.has_method("update_shard_display"):
		game_ui_instance.update_shard_display(shards_collected_count, shards_total_in_level)
