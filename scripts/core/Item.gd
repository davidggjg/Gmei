extends Resource
class_name Item
## Base data for anything that can live in the player's inventory.

enum ItemType { WEAPON, AMMO, HEALING, KEY, DOCUMENT }

@export var id: String = ""
@export var name_key: String = ""
@export var description_key: String = ""
@export var item_type: ItemType = ItemType.DOCUMENT
@export var stackable: bool = true
@export var max_stack: int = 20
@export var icon_color: Color = Color(0.6, 0.6, 0.6) ## placeholder swatch until real icons exist

## Weapon-only fields (ignored for other types)
@export var damage: float = 0.0
@export var fire_rate: float = 0.0 ## shots per second
@export var magazine_size: int = 0
@export var ammo_item_id: String = "" ## id of the Item this weapon consumes
@export var weapon_range: float = 30.0
@export var is_melee: bool = false

## Healing-only field
@export var heal_amount: float = 0.0
