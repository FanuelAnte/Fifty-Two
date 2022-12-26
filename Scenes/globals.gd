extends Node

var player_names = ["Stephen", "Thom", "Hans", "Austin", "Matt", "Reed", "Otto", "Peter", "Ed"]

var suits = ["Spades", "Clubs", "Diamonds", "Hearts"]
var faces = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]

var card_value_ranking = [
	[1, "Ace"],
	[2, "King"],
	[3, "Queen"],
	[4, "Jack"],
	[5, "10"],
	[6, "9"],
	[7, "8"],
	[8, "7"],
	[9, "6"],
	[10, "5"],
	[11, "4"],
	[12, "3"],
	[13, "2"]
]

var cards = []

#reset to default after every hand
var community_cards = ["-", "-", "-", "-", "-"]

var five_card_combinations = {
	"Four": [
		[1,2,3,4],
		[1,2,3,5],
		[1,2,4,5],
		[1,3,4,5],
		[2,3,4,5]
	],
	"Three": [
		[1,2,3],
		[1,2,4],
		[1,2,5],
		[1,3,4],
		[1,3,5],
		[2,3,4],
		[2,3,5],
		[2,4,5],
		[3,4,5],
		[1,4,5]
	],
	"Two": [
		[1,2],
		[1,3],
		[1,4],
		[1,5],
		[2,3],
		[2,4],
		[2,5],
		[3,4],
		[3,5],
		[4,5]
	]
}

var hand_rankings_reference = {
	"Royal Flush": ["Ace", "Jack", "Queen", "King", "10"],
} 

#reset to zero every round
var current_bet_amount = 0

var current_action = ""

var small_blind_amount = 10
var big_blind_amount = 20

var pot = 0


var rng = RandomNumberGenerator.new()

func _ready():
	set_deck()
	
func set_deck():
	for suit in suits:
		for face in faces:
			cards.append(face + " of " + suit)

func pick_card():
	rng.randomize()
	var card = cards[rng.randi_range(0, cards.size() - 1)]
	cards.erase(card)
	
	return card

func pick_name():
	rng.randomize()
	var player_name = player_names[rng.randi_range(0, player_names.size() - 1)]
	player_names.erase(player_name)
	
	return player_name
