extends Resource
class_name DeviceData

## ============================================
## DEVICE DATA — Ресурс для описания девайса
## ============================================

@export var device_id: String = ""              # Уникальный ключ, напр. "pager_silencer"
@export var display_name: String = ""           # Название для UI
@export var model_scene: PackedScene            # Ссылка на 3D-сцену девайса
@export var base_reward: int = 50               # Базовая выплата за ремонт
@export var is_anomalous: bool = false          # Флаг аномальности
@export var difficulty: int = 1                 # Сложность (1-5 звёзд)
@export var possible_faults: Array[FaultData] = []  # Список возможных поломок
