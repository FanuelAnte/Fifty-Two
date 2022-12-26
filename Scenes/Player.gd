extends Control

onready var name_lbl = $"%Name"
onready var cash_lbl = $"%Cash"

onready var hand_lbl = $"%Hand"

var types = ["", "Dealer", "Small Blind", "Big Blind"]

var actions = ["call_bet", "bet", "fold", "check", "raise_bet"]

var hole = []

var player_name = ""
var cash = 500
var type = 0

var is_active = true

func _ready():
	pass
	
func _process(delta):
	hint_tooltip = types[type] + "\n" + hole[0] + "\n" + hole[1]
	name_lbl.text = player_name
	cash_lbl.text = "$ " + str(cash)

func deal_hand():
	for i in range(2):
		hole.append(Globals.pick_card())

func create_player():
	player_name = Globals.pick_name()
	deal_hand()
	
func act(current_round):
	randomize()
	if is_active:
		rank_hand(current_round)
#		var action = actions[randi() % actions.size()]
#		Globals.current_action = player_name + ":  " + action
#		if action == "bet" or action == "raise_bet":
#			call(action, 30)
#		else:
#			call(action)

func rank_hand(current_round):
	var card_values = []
	var card_suits = []
	var card_value_indexes = []
	
	if current_round == 1:
		for card in hole:
			card_values.append(card.split(" ")[0])
			card_suits.append(card.split(" ")[2])
		
		#Sort card values
		card_values.sort_custom(self, "sort_cards")
		
		#Get card value indexes
		for card_value in card_values:
			for card_value_rank in Globals.card_value_ranking:
				if card_value_rank[1] == card_value:
					card_value_indexes.append(card_value_rank[0])
		
#		print(player_name + " " + str(card_values) + " " + str(card_value_indexes))
		
		if card_suits[0] == card_suits [1]:
			#check flush
			print(player_name + " is on a flush")
			
			#check royal flush
			if card_values[0] != card_values[1]:
				if card_values[0] in Globals.hand_rankings_reference["Royal Flush"] and card_values[1] in Globals.hand_rankings_reference["Royal Flush"]:
					print(player_name + " is on a royal flush")
				
		#check four of a kind, full house, three of a kind, two pair and one pair
		elif card_values[0] == card_values[1]:
			print(player_name + " is on a four of a kind, full house, three of a kind, two pair or one pair")
		
		#check straight
		elif card_value_indexes[0] == card_value_indexes[1] - 1:
			print(player_name + " is on a straight")
			#check straight flush
			if card_suits[0] == card_suits [1]:
				print(player_name + " is on a straight flush")
				
		else:
			print(player_name + " has rags")
			 
	elif current_round == 3:
		for card in hole:
			card_values.append(card.split(" ")[0])
			card_suits.append(card.split(" ")[2])
		
		for card in Globals.community_cards:
			if card != "-":
				card_values.append(card.split(" ")[0])
				card_suits.append(card.split(" ")[2])
			
		#Sort card values
		card_values.sort_custom(self, "sort_cards")
		
		#Get card value indexes
		for card_value in card_values:
			for card_value_rank in Globals.card_value_ranking:
				if card_value_rank[1] == card_value:
					card_value_indexes.append(card_value_rank[0])
		
		var broken_suit = false
		var royal = true
		var duplicate_card = false
		
		var consecutive = true
		
		var four_combinations = get_combinations(card_values, "Four")
		var three_combinations = get_combinations(card_values, "Three")
		var two_combinations = get_combinations(card_values, "Two")
		
		var four_of_a_kinds = []
		var three_of_a_kinds = []
		var pairs = []
		
		var has_four_of_a_kind = false
		var has_three_of_a_kind = false
		var has_pair = false
		
		var has_two_pairs = false
		
		var full_house = false
		
		for suit in card_suits:
			for i in range(card_suits.size()):
				if suit != card_suits[i]:
					broken_suit = true
					break
		
		for card in card_values:
			if !(card in Globals.hand_rankings_reference["Royal Flush"]):
				royal = false
				break
			
		for card in card_values:
			for i in range(card_values.size()):
				if card == card_values[i]:
					duplicate_card = true
					break
		
		for card_value_index in range(card_value_indexes.size() - 1):
			if card_value_indexes[card_value_index] != card_value_indexes[card_value_index + 1] - 1:
				consecutive = false
				break
		
		for combination in four_combinations:
			if combination[0] == combination[1] and combination[1] == combination[2] and combination[2] == combination[3]:
				has_four_of_a_kind = true
				four_of_a_kinds.append(combination)
		
		for combination in three_combinations:
			if combination[0] == combination[1] and combination[1] == combination[2]:
				has_three_of_a_kind = true
				three_of_a_kinds.append(combination)

		for combination in two_combinations:
			if combination[0] == combination[1]:
				has_pair = true
				pairs.append(combination)
				
		for three in three_of_a_kinds:
			for pair in pairs:
				if three[0] != pair[0]:
					full_house = true
		
		if pairs.size() > 1:
			if pairs[0] != pairs[1]:
				has_two_pairs = true
				
		#check royal flush
		if !broken_suit and !royal and !duplicate_card:
			print(player_name + " is on a royal flush")
		
		#check straight flush
		elif !broken_suit and consecutive:
			print(player_name + " is on a straight flush")
		
		#check four of a kind 
		elif has_four_of_a_kind:
			print(player_name + " is on a four of a kind")
		
		#check full house
		elif full_house:
			print(player_name + " is on a full house")
			
		#check flush
		#check smaller chunks(3 and 4) instead of all 5 cards
		elif !broken_suit:
			print(player_name + " is on a flush")
			
		#check straight
		elif consecutive:
			print(player_name + " is on a straight")
		
		#check three of a kind
		elif has_three_of_a_kind:
			print(player_name + " is on a three of a kind")
		
		#check two_pair
		elif has_two_pairs:
			print(player_name + " has two pairs")
		
		#check pair
		elif has_pair:
			print(player_name + " has a pair")
		
		else:
			print(player_name + " has rags")
		
func get_combinations(card_list, size):
	var combo_array = Globals.five_card_combinations[size]
	var new_combo_array = []
	
	for combo in combo_array:
		var new_combo = []
		
		for combo_val in combo:
			new_combo.append(card_list[combo_val - 1])
		
		new_combo_array.append(new_combo)
	
	return new_combo_array
	
	
func blind_bet():
	if type == 2:
		cash -= Globals.small_blind_amount
		Globals.pot += Globals.small_blind_amount
		Globals.current_bet_amount = Globals.small_blind_amount
	elif type == 3:
		cash -= Globals.big_blind_amount
		Globals.pot += Globals.big_blind_amount
		Globals.current_bet_amount = Globals.big_blind_amount
		
func call_bet():
	cash -= Globals.current_bet_amount
	Globals.pot += Globals.current_bet_amount
	
func bet(amount):
	cash -= amount
	Globals.pot += amount
	
func fold():
	is_active = false
	
func check():
	pass
	
func raise_bet(amount):
	cash -= Globals.current_bet_amount + amount
	Globals.pot += Globals.current_bet_amount + amount
	Globals.current_bet_amount = Globals.current_bet_amount + amount

func sort_cards(a, b):
	var rank_a
	var rank_b
	
	for i in Globals.card_value_ranking:
		if i[1] == a:
			rank_a = i[0]
			
	for i in Globals.card_value_ranking:
		if i[1] == b:
			rank_b = i[0]

	return rank_a < rank_b
