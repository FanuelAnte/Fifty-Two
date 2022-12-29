extends Control

onready var player_scene = load("res://Scenes/Player.tscn")

onready var player_list = $"%PlayerList"
onready var pot_lbl = $"%PotLbl"
onready var round_lbl = $"%RoundLbl"
onready var action_lbl = $"%ActionLbl"

onready var flop_card_1 = $"%Flop1"
onready var flop_card_2 = $"%Flop2"
onready var flop_card_3 = $"%Flop3"
onready var turn_card = $"%Turn"
onready var river_card = $"%River"

var blind_indexes = [0, 1, 2]

var active_player_count = 0
var current_round = 0

func _ready():
#	yield(get_tree().create_timer(1), "timeout")
	create_players()
	check_round()
	
func check_round():
	if current_round == 0:
		initial_round_bets()
	elif current_round == 1:
		print("---------------")
		first_round_bets()
	elif current_round == 2:
		flop()
	elif current_round == 3:
		print("---------------")
		standard_round_bets()
	elif current_round == 4:
		turn_or_river(3)
	elif current_round == 5:
		print("---------------")
		standard_round_bets()
	elif current_round == 6:
		turn_or_river(4)
	elif current_round == 7:
		print("---------------")
		standard_round_bets()
		
func initial_round_bets():
	check_players_status()
	assign_blinds()
	initial_blind_bets()
	current_round += 1
	check_round()
		
func initial_blind_bets():
	for player in player_list.get_children():
		player.blind_bet()

func first_round_bets():
#	Globals.previous_action = "Bet"
	check_players_status()
	for player_index in range(blind_indexes[2], active_player_count):
		player_list.get_child(player_index).act(current_round)
		
	for player_index in range(0, blind_indexes[2]):
		player_list.get_child(player_index).act(current_round)
	
	current_round += 1
	check_round()

func flop():
	for i in range(3):
		Globals.community_cards[i] = Globals.pick_card()
	current_round += 1
	check_round()
	
func standard_round_bets():
	check_players_status()
	for player_index in range(blind_indexes[1], player_list.get_child_count()):
		player_list.get_child(player_index).act(current_round)
		
	for player_index in range(0, blind_indexes[1]):
		player_list.get_child(player_index).act(current_round)
		
	current_round += 1
	check_round()
	
func turn_or_river(index):
	Globals.community_cards[index] = Globals.pick_card()
	current_round += 1
	check_round()
	
func assign_blinds():
	player_list.get_child(blind_indexes[0]).type = 1
	player_list.get_child(blind_indexes[1]).type = 2
	player_list.get_child(blind_indexes[2]).type = 3
	
	blind_indexes[0] = blind_indexes[1]
	blind_indexes[1] = blind_indexes[2]
	if blind_indexes[2] == player_list.get_child_count() - 1:
		blind_indexes[2] = 0
	else:
		blind_indexes[2] += 1
	
#This needs to be called at the start of every hand.
func check_players_status():
	active_player_count = 0
	for player in player_list.get_children():
		if player.is_active:
			active_player_count += 1
	
func create_players():
	for i in range(1, 6):
		var player = player_scene.instance()
		player_list.add_child(player)
		player.create_player()
	
	
func _process(delta):
	pot_lbl.text = str(Globals.pot)
	round_lbl.text = str(current_round)
	action_lbl.text = Globals.current_action
		
	flop_card_1.text = Globals.community_cards[0]
	flop_card_2.text = Globals.community_cards[1]
	flop_card_3.text = Globals.community_cards[2]
	turn_card.text = Globals.community_cards[3]
	river_card.text = Globals.community_cards[4]
