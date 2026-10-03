extends Node3D

## ============================================
## ORDER SPAWNER — Спавн новых заказов
## Вешается на узел OrderSpawner в workbench_v2.tscn
## ============================================

@onready var spawn_timer: Timer = $SpawnTimer

const SPAWN_DELAY: float = 2.5

# ============================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================

func _ready():
	print("🔧 OrderSpawner: _ready() вызван")
	
	# Проверяем, есть ли SpawnTimer
	if not spawn_timer:
		print("⚠️ SpawnTimer не найден! Создаём вручную...")
		spawn_timer = Timer.new()
		spawn_timer.one_shot = true
		spawn_timer.wait_time = SPAWN_DELAY
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		add_child(spawn_timer)
	else:
		print("✅ SpawnTimer найден: ", spawn_timer.name)
		# Проверяем, подключён ли timeout
		if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
			print("🔧 Подключаем timeout к _on_spawn_timer_timeout()")
			spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		else:
			print("✅ timeout уже подключён")
	
	# Подписываемся на сигнал order_completed
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.order_completed.connect(_on_order_completed)
		print("✅ OrderSpawner подключен к GameManager.order_completed")
	else:
		print("⚠️ GameManager не найден!")

# ============================================
# ОБРАБОТКА ЗАВЕРШЕНИЯ ЗАКАЗА
# ============================================

func _on_order_completed():
	print("📦 Заказ завершён! Новый девайс через ", SPAWN_DELAY, " сек...")
	print("🔍 spawn_timer = ", spawn_timer)
	
	if spawn_timer:
		print("🔍 Запускаем таймер...")
		spawn_timer.start(SPAWN_DELAY)
		print("🔍 Таймер запущен! time_left = ", spawn_timer.time_left, " сек")
	else:
		print("⚠️ spawn_timer НЕ НАЙДЕН!")

# ============================================
# СПАВН НОВОГО ДЕВАЙСА
# ============================================

func _on_spawn_timer_timeout():
	print("🚀 Спавним новый девайс...")
	
	var rm = get_node_or_null("/root/ResourceManager")
	if not rm:
		print("⚠️ ResourceManager не найден!")
		return
	
	var device_data = rm.get_random_device()
	if not device_data:
		print("⚠️ Нет доступных девайсов для спавна!")
		return
	
	print("📱 Выбран девайс: ", device_data.display_name)
	print("   - ID: ", device_data.device_id)
	print("   - Награда: $", device_data.base_reward)
	print("   - Аномальный: ", device_data.is_anomalous)
	
	# TODO (Этап 3): Инстанцировать 3D-модель и анимировать вылет из трубы
	print("🔧 [ЗАГЛУШКА] Девайс должен вылететь из трубы!")
