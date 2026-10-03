extends Panel

## ============================================
## MARKET PANEL — UI маркетплейса
## ============================================

@onready var item_list: VBoxContainer = $ItemList
@onready var item_content: RichTextLabel = $ItemContent
@onready var buy_button: Button = $BuyButton
@onready var close_button: Button = $MarketCloseButton
@onready var balance_label: Label = $BalanceLabel

# ============================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================

func _ready():
	close_button.pressed.connect(_on_close_pressed)
	buy_button.pressed.connect(_on_buy_pressed)
	buy_button.disabled = true
	
	_populate_item_list()
	_update_balance()
	
	# Подписка на изменение денег
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.money_changed.connect(_on_money_changed)
	
	visible = false
	print("✅ MarketPanel готов")

# ============================================
# СПИСОК ТОВАРОВ
# ============================================

func _populate_item_list():
	for child in item_list.get_children():
		child.queue_free()
	
	var mm = get_node_or_null("/root/MarketManager")
	if not mm:
		return
	
	for item in mm.get_all_items():
		var btn = Button.new()
		btn.text = item.display_name + " — $" + str(item.price)
		btn.custom_minimum_size = Vector2(480, 40)
		btn.pressed.connect(_on_item_selected.bind(item.item_id))
		item_list.add_child(btn)

# ============================================
# ВЫБОР ТОВАРА
# ============================================

func _on_item_selected(item_id: String):
	var mm = get_node_or_null("/root/MarketManager")
	if not mm:
		return
	
	mm.select_item(item_id)
	item_content.text = "[b]" + mm.selected_item.display_name + "[/b]\n\n" + mm.selected_item.description + "\n\n[i]Цена: $" + str(mm.selected_item.price) + "[/i]"
	buy_button.disabled = false

# ============================================
# ПОКУПКА
# ============================================

func _on_buy_pressed():
	var mm = get_node_or_null("/root/MarketManager")
	if mm:
		mm.buy_selected()
	# Закрываем панель
	visible = false

# ============================================
# ОБНОВЛЕНИЕ БАЛАНСА
# ============================================

func _on_money_changed(_new_amount: int):
	_update_balance()

func _update_balance():
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		balance_label.text = "💰 $" + str(gm.money)

# ============================================
# ЗАКРЫТИЕ
# ============================================

func _on_close_pressed():
	visible = false
	print("🛒 MarketPanel закрыт")
