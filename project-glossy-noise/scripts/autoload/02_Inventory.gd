extends Node

## ============================================
## INVENTORY — Система инвентаря (классические слоты)
## ============================================

signal inventory_updated(slots: Array)
signal item_used(slot_index: int, item_data: Dictionary)

# ------ НАСТРОЙКИ ------
const MAX_SLOTS: int = 6

# ------ ДАННЫЕ ------
var slots: Array = []  # Каждый слот: { "item_id": String, "item_name": String, "icon": Texture, "data": {} }

# ============================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================

func _ready():
	# Создаём пустые слоты
	_clear_inventory()

func _clear_inventory():
	slots.clear()
	for i in range(MAX_SLOTS):
		slots.append(null)  # null = пустой слот
	
	emit_signal("inventory_updated", slots)

# ============================================
# ОСНОВНЫЕ МЕТОДЫ
# ============================================

func add_item(item_id: String, item_name: String = "", icon: Texture = null, data: Dictionary = {}) -> bool:
	if item_name == "":
		item_name = item_id # Если имя не передали, назовём по ID
	"""Добавляет предмет в первый свободный слот. Возвращает true, если успешно."""
	for i in range(MAX_SLOTS):
		if slots[i] == null:
			slots[i] = {
				"item_id": item_id,
				"item_name": item_name,
				"icon": icon,
				"data": data
			}
			emit_signal("inventory_updated", slots)
			print("📦 Добавлен предмет: ", item_name, " (слот ", i, ")")
			return true
	
	print("❌ Инвентарь полон!")
	return false

func remove_item(slot_index: int) -> Dictionary:
	"""Удаляет предмет из слота и возвращает его данные."""
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return {}
	
	var item = slots[slot_index]
	if item == null:
		return {}
	
	slots[slot_index] = null
	emit_signal("inventory_updated", slots)
	print("🗑️ Удалён предмет из слота ", slot_index, ": ", item.item_name)
	return item

func use_item(slot_index: int) -> bool:
	"""Использует предмет из слота (вызывает сигнал)."""
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return false
	
	var item = slots[slot_index]
	if item == null:
		return false
	
	emit_signal("item_used", slot_index, item)
	print("🔧 Использован предмет: ", item.item_name)
	return true

func get_item(slot_index: int) -> Dictionary:
	"""Возвращает данные предмета из слота (без удаления)."""
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return {}
	
	var item = slots[slot_index]
	if item == null:
		return {}
	
	return item

func has_item(item_id: String) -> bool:
	"""Проверяет, есть ли предмет в инвентаре."""
	for slot in slots:
		if slot != null and slot.item_id == item_id:
			return true
	return false

func get_slot_by_item(item_id: String) -> int:
	"""Возвращает индекс слота с предметом или -1."""
	for i in range(MAX_SLOTS):
		if slots[i] != null and slots[i].item_id == item_id:
			return i
	return -1

func clear_inventory():
	"""Очищает инвентарь."""
	_clear_inventory()
	print("🗑️ Инвентарь очищен")

# ============================================
# ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
# ============================================

func is_full() -> bool:
	"""Проверяет, полон ли инвентарь."""
	for slot in slots:
		if slot == null:
			return false
	return true

func get_free_slots_count() -> int:
	"""Возвращает количество свободных слотов."""
	var count = 0
	for slot in slots:
		if slot == null:
			count += 1
	return count

func get_item_count() -> int:
	"""Возвращает количество предметов в инвентаре."""
	var count = 0
	for slot in slots:
		if slot != null:
			count += 1
	return count

func remove_item_by_id(item_id: String) -> bool:
	for i in range(MAX_SLOTS):
		if slots[i] != null and slots[i].get("item_id") == item_id:
			slots[i] = null
			emit_signal("inventory_updated", slots)
			print("🗑️ Удалён предмет по ID: ", item_id)
			return true
	return false
