extends Area2D

signal shard_collected # 定义一个信号，当碎片被收集时发出

# Area2D的body_entered信号会自动连接到这个函数（如果在编辑器中连接过）
func _on_body_entered(body: Node) -> void:
	# 检查进入区域的是否为玩家 (你可以给玩家节点添加到一个 "player" 组中进行更可靠的检查)
	if body.is_in_group("player"): # 假设你给Player节点添加了 "player" 组
		emit_signal("shard_collected")
		queue_free() # 销毁碎片自身
