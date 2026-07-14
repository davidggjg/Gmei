extends Node
## Registry of every Item in the game, built in code (no .tres assets needed).

var items: Dictionary = {}

const HANDGUN := "handgun"
const SHOTGUN := "shotgun"
const KNIFE := "knife"
const AMMO_PISTOL := "ammo_pistol"
const AMMO_SHOTGUN := "ammo_shotgun"
const HERB_GREEN := "herb_green"
const FIRST_AID := "first_aid"
const KEY_ORNATE := "key_ornate"
const KEY_RUSTY := "key_rusty"
const DOCUMENT := "document"

func _ready() -> void:
	_register_weapons()
	_register_ammo()
	_register_healing()
	_register_keys_and_docs()

func _add(item: Item) -> void:
	items[item.id] = item

func _register_weapons() -> void:
	var handgun := Item.new()
	handgun.id = HANDGUN
	handgun.name_key = "ITEM_HANDGUN"
	handgun.item_type = Item.ItemType.WEAPON
	handgun.stackable = false
	handgun.damage = 22.0
	handgun.fire_rate = 3.0
	handgun.magazine_size = 12
	handgun.ammo_item_id = AMMO_PISTOL
	handgun.weapon_range = 40.0
	handgun.icon_color = Color(0.55, 0.55, 0.6)
	_add(handgun)

	var shotgun := Item.new()
	shotgun.id = SHOTGUN
	shotgun.name_key = "ITEM_SHOTGUN"
	shotgun.item_type = Item.ItemType.WEAPON
	shotgun.stackable = false
	shotgun.damage = 65.0
	shotgun.fire_rate = 1.1
	shotgun.magazine_size = 6
	shotgun.ammo_item_id = AMMO_SHOTGUN
	shotgun.weapon_range = 14.0
	shotgun.icon_color = Color(0.4, 0.3, 0.2)
	_add(shotgun)

	var knife := Item.new()
	knife.id = KNIFE
	knife.name_key = "ITEM_KNIFE"
	knife.item_type = Item.ItemType.WEAPON
	knife.stackable = false
	knife.is_melee = true
	knife.damage = 18.0
	knife.fire_rate = 1.8
	knife.weapon_range = 1.6
	knife.icon_color = Color(0.75, 0.75, 0.8)
	_add(knife)

func _register_ammo() -> void:
	var ammo_pistol := Item.new()
	ammo_pistol.id = AMMO_PISTOL
	ammo_pistol.name_key = "ITEM_AMMO_PISTOL"
	ammo_pistol.item_type = Item.ItemType.AMMO
	ammo_pistol.max_stack = 60
	ammo_pistol.icon_color = Color(0.7, 0.6, 0.2)
	_add(ammo_pistol)

	var ammo_shotgun := Item.new()
	ammo_shotgun.id = AMMO_SHOTGUN
	ammo_shotgun.name_key = "ITEM_AMMO_SHOTGUN"
	ammo_shotgun.item_type = Item.ItemType.AMMO
	ammo_shotgun.max_stack = 24
	ammo_shotgun.icon_color = Color(0.8, 0.4, 0.1)
	_add(ammo_shotgun)

func _register_healing() -> void:
	var herb := Item.new()
	herb.id = HERB_GREEN
	herb.name_key = "ITEM_HERB_GREEN"
	herb.item_type = Item.ItemType.HEALING
	herb.max_stack = 6
	herb.heal_amount = 30.0
	herb.icon_color = Color(0.2, 0.7, 0.25)
	_add(herb)

	var first_aid := Item.new()
	first_aid.id = FIRST_AID
	first_aid.name_key = "ITEM_FIRST_AID"
	first_aid.item_type = Item.ItemType.HEALING
	first_aid.max_stack = 4
	first_aid.heal_amount = 60.0
	first_aid.icon_color = Color(0.8, 0.15, 0.15)
	_add(first_aid)

func _register_keys_and_docs() -> void:
	var key_ornate := Item.new()
	key_ornate.id = KEY_ORNATE
	key_ornate.name_key = "ITEM_KEY_ORNATE"
	key_ornate.item_type = Item.ItemType.KEY
	key_ornate.stackable = false
	key_ornate.icon_color = Color(0.85, 0.7, 0.2)
	_add(key_ornate)

	var key_rusty := Item.new()
	key_rusty.id = KEY_RUSTY
	key_rusty.name_key = "ITEM_KEY_RUSTY"
	key_rusty.item_type = Item.ItemType.KEY
	key_rusty.stackable = false
	key_rusty.icon_color = Color(0.5, 0.3, 0.2)
	_add(key_rusty)

	var document := Item.new()
	document.id = DOCUMENT
	document.name_key = "ITEM_DOCUMENT"
	document.item_type = Item.ItemType.DOCUMENT
	document.stackable = false
	document.icon_color = Color(0.9, 0.87, 0.75)
	_add(document)

func get_item(id: String) -> Item:
	return items.get(id)
