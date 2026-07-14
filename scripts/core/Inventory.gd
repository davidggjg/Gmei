extends Node
class_name Inventory
## Slot-less stacking inventory: {item_id: String -> count: int}.
## Attach as a child of the player (or a BR bot, for loot-aware AI).

signal inventory_changed
signal item_added(item_id: String, count: int)
signal item_removed(item_id: String, count: int)
signal weapon_equipped(item_id: String)

@export var max_unique_items: int = 20

var stacks: Dictionary = {} ## item_id -> count
var equipped_weapon_id: String = ""
var _magazine_ammo: Dictionary = {} ## item_id (weapon) -> rounds currently chambered

func add_item(item_id: String, count: int = 1) -> bool:
	var item := ItemDB.get_item(item_id)
	if item == null or count <= 0:
		return false
	if not stacks.has(item_id):
		if stacks.size() >= max_unique_items:
			return false
		stacks[item_id] = 0
	var cap: int = item.max_stack if item.stackable else 1
	stacks[item_id] = mini(stacks[item_id] + count, cap)
	item_added.emit(item_id, count)
	inventory_changed.emit()
	if item.item_type == Item.ItemType.WEAPON and equipped_weapon_id == "":
		equip_weapon(item_id)
	return true

func remove_item(item_id: String, count: int = 1) -> bool:
	if not has_item(item_id, count):
		return false
	stacks[item_id] -= count
	if stacks[item_id] <= 0:
		stacks.erase(item_id)
	item_removed.emit(item_id, count)
	inventory_changed.emit()
	return true

func has_item(item_id: String, count: int = 1) -> bool:
	return stacks.get(item_id, 0) >= count

func get_count(item_id: String) -> int:
	return stacks.get(item_id, 0)

func equip_weapon(item_id: String) -> void:
	if not stacks.has(item_id):
		return
	var item := ItemDB.get_item(item_id)
	if item == null or item.item_type != Item.ItemType.WEAPON:
		return
	equipped_weapon_id = item_id
	if not _magazine_ammo.has(item_id):
		_magazine_ammo[item_id] = item.magazine_size if not item.is_melee else 0
	weapon_equipped.emit(item_id)

func get_equipped_weapon() -> Item:
	if equipped_weapon_id == "":
		return null
	return ItemDB.get_item(equipped_weapon_id)

## Cycles to the next owned weapon (wraps around), skipping the one already
## equipped. Order is ItemDB.WEAPON_ORDER (weakest to strongest).
func cycle_weapon(direction: int = 1) -> void:
	var owned: Array = []
	for id in ItemDB.WEAPON_ORDER:
		if stacks.has(id):
			owned.append(id)
	if owned.size() <= 1:
		return
	var idx := owned.find(equipped_weapon_id)
	if idx == -1:
		idx = 0
	var next_idx := posmod(idx + direction, owned.size())
	equip_weapon(owned[next_idx])

func current_magazine() -> int:
	return _magazine_ammo.get(equipped_weapon_id, 0)

## Consumes one round from the current magazine, or auto-reloads from spare
## ammo if empty. Returns true if a shot can be fired.
func try_consume_round() -> bool:
	var weapon := get_equipped_weapon()
	if weapon == null or weapon.is_melee:
		return weapon != null
	var mag: int = _magazine_ammo.get(equipped_weapon_id, 0)
	if mag <= 0:
		return false
	_magazine_ammo[equipped_weapon_id] = mag - 1
	inventory_changed.emit()
	return true

func reload_equipped() -> bool:
	var weapon := get_equipped_weapon()
	if weapon == null or weapon.is_melee:
		return false
	var needed: int = weapon.magazine_size - _magazine_ammo.get(equipped_weapon_id, 0)
	if needed <= 0:
		return false
	var available: int = get_count(weapon.ammo_item_id)
	var to_load: int = mini(needed, available)
	if to_load <= 0:
		return false
	remove_item(weapon.ammo_item_id, to_load)
	_magazine_ammo[equipped_weapon_id] = _magazine_ammo.get(equipped_weapon_id, 0) + to_load
	inventory_changed.emit()
	return true

## Applies a healing item's effect to `health` and consumes it.
func use_healing_item(item_id: String, health: Health) -> bool:
	var item := ItemDB.get_item(item_id)
	if item == null or item.item_type != Item.ItemType.HEALING:
		return false
	if not has_item(item_id):
		return false
	health.heal(item.heal_amount)
	remove_item(item_id, 1)
	return true
