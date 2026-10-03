extends Node

## ============================================
## MARKET MANAGER — Даркнет-маркетплейс
## Autoload
## ============================================

var items: Dictionary = {}        # item_id -> ItemData
var selected_item: ItemData = null

func _ready():
	_load_items("res://resources/items/")
	print("🛒 MarketManager: загружено товаров: ", items.size())

func _load_items(path: String):
	var dir = DirAccess.open(path)
	if not dir:
		print("⚠️ MarketManager: папка не найдена: ", path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res = load(path + file_name)
			if res and res is ItemData:
				items[res.item_id] = res
				print("✅ Загружен товар: ", res.display_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func get_all_items() -> Array:
	return items.values()

func select_item(item_id: String):
	if items.has(item_id):
		selected_item = items[item_id]
		print("🛒 Выбран товар: ", selected_item.display_name)

func buy_selected() -> bool:
	if not selected_item:
		print("⚠️ Товар не выбран!")
		return false
	
	var gm = get_node_or_null("/root/GameManager")
	if not gm:
		return false
	
	# Проверяем деньги
	if gm.money < selected_item.price:
		print("❌ Недостаточно денег!")
		return false
	
	# Списываем
	gm.spend_money(selected_item.price)
	
	# Добавляем в инвентарь
	var inv = get_node_or_null("/root/Inventory")
	if inv:
		inv.add_item(selected_item.item_id, selected_item.display_name, null, {"type": selected_item.category})
	
	print("✅ Куплено: ", selected_item.display_name)
	selected_item = null
	return true
