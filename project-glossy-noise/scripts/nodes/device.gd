extends Node3D

## ============================================
## DEVICE — Управляет всем: винты, крышка, гнездо, труба
## ============================================

@onready var cover: MeshInstance3D = $Cover
@onready var board: MeshInstance3D = $Board
@onready var battery_socket: MeshInstance3D = $BatterySocket
@onready var screws: Array = [$Screw1, $Screw2, $Screw3, $Screw4]

var battery_mesh: MeshInstance3D = null
var cover_start_position: Vector3

var is_repaired: bool = false
var is_cover_installed: bool = true
var screws_installed: int = 4
var is_assembled: bool = false

# ============================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================

func _ready():
	# Запоминаем стартовую позицию крышки
	cover_start_position = cover.position
	
	# Добавляем батарейку в инвентарь
	var inv = _get_inventory()
	if inv:
		inv.add_item("battery", "Батарейка", null, {"type": "battery"})
		print("🔋 Батарейка добавлена в инвентарь!")
	else:
		print("⚠️ Inventory не найден!")
	
	# Ищем BatteryMesh
	if battery_socket:
		for child in battery_socket.get_children():
			if child is MeshInstance3D and child.name == "BatteryMesh":
				battery_mesh = child
				break
	
	# Считаем винты
	screws_installed = 0
	for screw in screws:
		if screw.visible:
			screws_installed += 1
	print("🔩 Винтов на месте: ", screws_installed)

# ============================================
# КЛИК ПО ВИНТУ
# ============================================

func click_screw(screw_index: int):
	var screw = screws[screw_index]
	if not screw:
		return
	
	if screw.visible:
		var inv = _get_inventory()
		if inv:
			inv.add_item("screw", "Винт", null, {"type": "screw"})
		screw.visible = false
		screws_installed -= 1
		print("🔩 Винт откручен! Осталось: ", screws_installed)
		
		if screws_installed <= 0:
			_remove_cover()
	else:
		if not is_cover_installed:
			print("⚠️ Сначала верни крышку!")
			return
		
		var inv = _get_inventory()
		if not inv or not inv.has_item("screw"):
			print("❌ Нет винтов в инвентаре!")
			return
		
		inv.remove_item_by_id("screw")
		screw.visible = true
		screws_installed += 1
		print("🔩 Винт закручен! Установлено: ", screws_installed)
		_check_assembly()

# ============================================
# КЛИК ПО КРЫШКЕ
# ============================================

func click_cover():
	# Крышка на месте, батарейки нет → снимаем (только если все винты откручены)
	if is_cover_installed and not is_repaired:
		if screws_installed > 0:
			print("⚠️ Сначала открути все винты! Осталось: ", screws_installed)
			return
		_remove_cover()
		print("📦 Крышка снята")
	# Крышка снята, батарейка есть → ставим обратно
	elif not is_cover_installed and is_repaired:
		_install_cover()
		print("📦 Крышка установлена")
	elif is_cover_installed and is_repaired:
		print("⚠️ Крышка уже на месте")
	else:
		print("⚠️ Сначала вставь батарейку в гнездо!")

# ============================================
# КЛИК ПО ГНЕЗДУ
# ============================================

func click_socket():
	if is_repaired:
		print("⚠️ Батарейка уже вставлена!")
		return
	
	if is_cover_installed:
		print("⚠️ Сначала сними крышку!")
		return
	
	var inv = _get_inventory()
	if not inv:
		print("⚠️ Inventory не найден!")
		return
	
	if not inv.has_item("battery"):
		print("❌ Нет батарейки в инвентаре!")
		return
	
	inv.remove_item_by_id("battery")
	if battery_mesh:
		battery_mesh.visible = true
	is_repaired = true
	print("🔋 Батарейка вставлена! Теперь можно вернуть крышку.")

# ============================================
# КЛИК ПО ТРУБЕ
# ============================================

func click_tube():
	if not is_repaired:
		print("❌ Девайс ещё не починен! Вставь батарейку.")
		return
	
	if not _check_assembly():
		print("⚠️ Девайс не собран! (Крышка + 4 винта)")
		return
	
	print("📦 Отправка девайса по пневмопочте...")
	
	var funnel = get_node_or_null("../PneumoTube/FunnelPos")
	var target = funnel.global_position if funnel else Vector3(0, 1.5, 0)
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", target + Vector3(0, 0.5, 0), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.35)
	
	await tween.finished
	
	var gm = _get_game_manager()
	if gm:
		# Временно заполняем current_order (заглушка до системы заказов)
		gm.current_order = {"name": "Пейджер-Молчун", "reward": 50}
		gm.finish_order()  # Начислит деньги + emit order_completed
	else:
		print("⚠️ GameManager не найден!")
	
	queue_free()
	print("✅ Заказ отправлен! +50 монет.")

# ============================================
# УПРАВЛЕНИЕ КРЫШКОЙ (СДВИГ, НЕ СКРЫТИЕ!)
# ============================================

func _remove_cover():
	if not is_cover_installed:
		return
	is_cover_installed = false
	board.visible = true
	if battery_socket:
		battery_socket.visible = true
	
	# Сдвигаем крышку в сторону
	var tween = create_tween()
	tween.tween_property(cover, "position", cover_start_position + Vector3(-0.35, -0.1, 0), 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(cover, "rotation", Vector3(0, 0, 0.3), 0.4)

func _install_cover():
	if is_cover_installed:
		return
	is_cover_installed = true
	board.visible = false
	if battery_socket:
		battery_socket.visible = false
	
	# Возвращаем крышку
	var tween = create_tween()
	tween.tween_property(cover, "position", cover_start_position, 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(cover, "rotation", Vector3(0, 0, 0), 0.4)
	
	_check_assembly()

# ============================================
# ПРОВЕРКА СБОРКИ
# ============================================

func _check_assembly() -> bool:
	is_assembled = (is_cover_installed and screws_installed >= 4)
	print("🔧 Сборка: ", "✅ ГОТОВО" if is_assembled else "❌ не собрано")
	return is_assembled

# ============================================
# ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
# ============================================

func _get_inventory():
	for child in get_tree().root.get_children():
		if child.name.to_lower() == "inventory":
			return child
	return null

func _get_game_manager():
	for child in get_tree().root.get_children():
		if child.name.to_lower() == "gamemanager":
			return child
	return null
