extends Control

signal action_selected
signal just_acted

onready var name_lbl = $"%Name"
onready var cash_lbl = $"%Cash"

onready var hand_lbl = $"%Hand"

onready var actions_panel = $"%Panel"
onready var bet_amount_spinner = $"%BetAmnt"
onready var raise_amount_spinner = $"%RaiseAmnt"

onready var bet_btn = $"%BetBtn"
onready var call_btn = $"%CallBtn"
onready var check_btn = $"%CheckBtn"
onready var fold_btn = $"%FoldBtn"
onready var raise_btn = $"%RaiseBtn"


var types = ["", "Dealer", "Small Blind", "Big Blind"]

var actions = ["call_bet", "bet", "fold", "check", "raise_bet"]

var apprehensive_actions = [2, 3]

var aggressive_actions = [0, 4]

var hole = []

var player_name = ""
var cash = 500
var type = 0

var is_active = true

var is_player = false

var hand_rank = 10

var winning_hand = []

func _ready():
	connect("just_acted", self, "act", [0])
	
func _process(delta):
	hint_tooltip = types[type] + "\n" + hole[0] + "\n" + hole[1] + "\n" + str(is_player) + "\n" + str(winning_hand)
	name_lbl.text = player_name
	cash_lbl.text = "$ " + str(cash)
	if is_player:
		if Globals.current_round <= 8:
			actions_panel.show()
		else:
			actions_panel.hide()
			
			
func deal_hand():
	for i in range(2):
		hole.append(Globals.pick_card())

func create_player():
	player_name = Globals.pick_name()
	deal_hand()
	
func showdown():
	var showdown_info = {}
	var final_hand_rank = rank_hand(7)
	
	showdown_info[player_name] = [final_hand_rank, winning_hand]
	
	return showdown_info
	
func act(current_round):
	var previous_action = Globals.previous_action
	
	hand_rank = rank_hand(current_round)
	
#	if is_active:
#		print(player_name + " " + str(hand_rank) + " " + Globals.hand_rankings_names[hand_rank])
	
	if !is_player:
		randomize()
		if is_active:
#			emit_signal("just_acted")
			if Globals.active_player_count > 1:
				
#				print(player_name + " hand rank " + str(hand_rank))
				
				if current_round == 1:
					var action = actions[aggressive_actions[randi() % aggressive_actions.size()]]
					if action == "raise_bet":
						call(action, Globals.big_blind_amount)
					else:
						call(action)
							
				elif current_round == 3 or current_round == 5 or current_round == 7:
					if hand_rank < 10:
						if previous_action == "-" or previous_action == "Fold" or previous_action == "Check":
							if cash >= Globals.big_blind_amount:
								bet(Globals.big_blind_amount)
							else:
								check()
						else:
							var action = actions[aggressive_actions[randi() % aggressive_actions.size()]]
							if action == "raise_bet":
								call(action, Globals.big_blind_amount)
							else:
								call(action)
					else:
						if previous_action == "-" or previous_action == "Fold" or previous_action == "Check":
							var action = actions[apprehensive_actions[randi() % apprehensive_actions.size()]]
							call(action)
						else:
							fold()
							
			elif Globals.active_player_count == 1:
				print(player_name + " wins")
				
	if is_player:
		if is_active:
			if Globals.active_player_count > 1:
				if previous_action == "-" or previous_action == "Fold" or previous_action == "Check":
					bet_amount_spinner.min_value = Globals.big_blind_amount
					bet_amount_spinner.max_value = cash
						
					raise_amount_spinner.editable = false
					call_btn.disabled = true
					raise_btn.disabled = true
					bet_btn.disabled = false
					check_btn.disabled = false
					bet_amount_spinner.editable = true
				else:
					raise_amount_spinner.min_value = Globals.big_blind_amount
					raise_amount_spinner.max_value = cash
						
					bet_amount_spinner.editable = false
					bet_btn.disabled = true
					check_btn.disabled = true
					call_btn.disabled = false
					raise_btn.disabled = false
					raise_amount_spinner.editable = true
					
				yield(self, "action_selected")
				emit_signal("just_acted")
				
			elif Globals.active_player_count == 1:
				print(player_name + " wins")
			
		
func rank_hand(current_round):
	var card_values = []
	var card_suits = []
	var card_value_indexes = []
	
	var rank = hand_rank
	
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
#			print(player_name + " is on a flush")
			rank = Globals.hand_rankings["Flush"]
			
			#check royal flush
			if card_values[0] != card_values[1]:
				if card_values[0] in Globals.hand_rankings_reference["Royal Flush"] and card_values[1] in Globals.hand_rankings_reference["Royal Flush"]:
#					print(player_name + " is on a royal flush")
					rank = Globals.hand_rankings["Royal Flush"]
				
		#check four of a kind, full house, three of a kind, two pair and one pair
		elif card_values[0] == card_values[1]:
#			print(player_name + " is on a four of a kind, full house, three of a kind, two pair or one pair")
			rank = Globals.hand_rankings["Four of a Kind"]
		
		#check straight
		elif card_value_indexes[0] == card_value_indexes[1] - 1:
#			print(player_name + " is on a straight")
			rank = Globals.hand_rankings["Straight"]
			
			#check straight flush
			if card_suits[0] == card_suits [1]:
#				print(player_name + " is on a straight flush")
				rank = Globals.hand_rankings["Straight Flush"]
				
		else:
#			print(player_name + " has rags")
			rank = Globals.hand_rankings["Rags"]
			 
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
		
		rank = post_flop_round_ranking(card_values, card_suits, card_value_indexes)
		winning_hand = card_values
			
	elif current_round == 5:
		var five_card_combos = []
		
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
					
		five_card_combos = get_combinations(card_values, "Six", "Five")
		
		for hand in five_card_combos:
			if rank > post_flop_round_ranking(hand, card_suits, card_value_indexes):
				rank = post_flop_round_ranking(hand, card_suits, card_value_indexes)
				winning_hand = hand
				
	elif current_round == 7:
		var five_card_combos = []
		
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
					
		five_card_combos = get_combinations(card_values, "Seven", "Five")
		
		for hand in five_card_combos:
			if rank > post_flop_round_ranking(hand, card_suits, card_value_indexes):
				rank = post_flop_round_ranking(hand, card_suits, card_value_indexes)
				winning_hand = hand
				
	return rank
	
func get_combinations(card_list, hand_size, chunk_size):
	var combo_array = []
	
	if hand_size == "Five":
		combo_array = Globals.five_card_combinations[chunk_size]
	elif hand_size == "Six":
		combo_array = Globals.six_card_combinations[chunk_size]
	elif hand_size == "Seven":
		combo_array = Globals.seven_card_combinations[chunk_size]
		
	
	var new_combo_array = []
	
	for combo in combo_array:
		var new_combo = []
		
		for combo_val in combo:
			new_combo.append(card_list[combo_val - 1])
		
		new_combo_array.append(new_combo)
	
	return new_combo_array

func post_flop_round_ranking(card_values, card_suits, card_value_indexes):
	var broken_suit = false
	var royal = true
	var duplicate_card = false
	
	var consecutive = true
	
	var four_combinations = get_combinations(card_values, "Five", "Four")
	var three_combinations = get_combinations(card_values, "Five", "Three")
	var two_combinations = get_combinations(card_values, "Five", "Two")
	
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
#		print(player_name + " is on a royal flush")
		return Globals.hand_rankings["Royal Flush"]
	
	#check straight flush
	elif !broken_suit and consecutive:
#		print(player_name + " is on a straight flush")
		return Globals.hand_rankings["Straight Flush"]
	
	#check four of a kind 
	elif has_four_of_a_kind:
#		print(player_name + " is on a four of a kind")
		return Globals.hand_rankings["Four of a Kind"]
	
	#check full house
	elif full_house:
#		print(player_name + " is on a full house")
		return Globals.hand_rankings["Full House"]
		
	#check flush
	#check smaller chunks(3 and 4) instead of all 5 cards
	elif !broken_suit:
#		print(player_name + " is on a flush")
		return Globals.hand_rankings["Flush"]
		
	#check straight
	elif consecutive:
#		print(player_name + " is on a straight")
		return Globals.hand_rankings["Straight"]
	
	#check three of a kind
	elif has_three_of_a_kind:
#		print(player_name + " is on a three of a kind")
		return Globals.hand_rankings["Three of a Kind"]
	
	#check two_pair
	elif has_two_pairs:
#		print(player_name + " has two pairs")
		return Globals.hand_rankings["Two Pair"]
	
	#check pair
	elif has_pair:
#		print(player_name + " has a pair")
		return Globals.hand_rankings["Pair"]
	
	else:
#		print(player_name + " has rags")
		return Globals.hand_rankings["Rags"]
	
func blind_bet():
	if type == 2:
		cash -= Globals.small_blind_amount
		Globals.pot += Globals.small_blind_amount
		Globals.current_bet_amount = Globals.small_blind_amount
		Globals.previous_action = "Bet"
		
	elif type == 3:
		cash -= Globals.big_blind_amount
		Globals.pot += Globals.big_blind_amount
		Globals.current_bet_amount = Globals.big_blind_amount
		Globals.previous_action = "Bet"
		
func call_bet():
	if cash >= Globals.current_bet_amount:
		cash -= Globals.current_bet_amount
		Globals.pot += Globals.current_bet_amount
		Globals.previous_action = "Call"
#		print(player_name + " Calls " + str(Globals.current_bet_amount))
	else:
		fold()
		
func bet(amount):
	cash -= amount
	Globals.pot += amount
	Globals.current_bet_amount = amount
	Globals.previous_action = "Bet"
#	print(player_name + " Bets " + str(amount))
	
func fold():
	is_active = false
	set_modulate(Color(1, 1, 1, 0.3))
#	Globals.previous_action = "Fold"
#	print(player_name + " Folds")
	
func check():
	Globals.previous_action = "Check"
#	print(player_name + " Checks")
	
func raise_bet(amount):
	if cash >= Globals.current_bet_amount + amount:
		cash -= Globals.current_bet_amount + amount
		Globals.pot += Globals.current_bet_amount + amount
		Globals.current_bet_amount = Globals.current_bet_amount + amount
		Globals.previous_action = "Raise"
#		print(player_name + " Raises " + str(amount))
	else:
		call_bet()
	
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

func _on_BetBtn_pressed():
	bet(bet_amount_spinner.value)
	emit_signal("action_selected")

func _on_CallBtn_pressed():
	call_bet()
	emit_signal("action_selected")

func _on_FoldBtn_pressed():
	fold()
	emit_signal("action_selected")

func _on_RaiseBtn_pressed():
	raise_bet(raise_amount_spinner.value)
	emit_signal("action_selected")

func _on_CheckBtn_pressed():
	check()
	emit_signal("action_selected")

