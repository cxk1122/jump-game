extends Control

# 假设你在GameUI场景中有一个Label节点叫 "ShardCountLabel"
@onready var shard_count_label: Label = $ShardCountLabel 

func update_shard_display(collected: int, total: int) -> void:
	if shard_count_label:
		shard_count_label.text = "Shards: %d / %d" % [collected, total]
	else:
		print("Error: ShardCountLabel not found in UI.")

# 当场景加载时，可以先显示初始状态
func _ready() -> void:
	if shard_count_label:
		shard_count_label.text = "Shards: 0 / 0" # 初始文本
	else:
		print("Error: ShardCountLabel not found in UI during _ready.")
