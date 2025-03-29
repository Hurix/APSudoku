extends Control

@onready var chat_npc_timers : Dictionary = {}
var connected : bool = false
var regions

func _ready():
	get_parent().find_child("LabelAuthfile").text = $Gift.initial_channel
	regions = get_node("/root/SudokuClient/Tabs/Sudoku/%Regions")
	if not regions:
		print_debug("cant find sudoku regions")

func chat_message(data : SenderData, msg : String) -> void:
	$ChatContainer.put_chat(data, msg)

func no_permission(_cmd_info : CommandInfo) -> void:
	$Gift.chat("no.")

func _process(_delta: float) -> void:
	connected = $Gift.connected

# Check the CommandInfo class for the available info of the cmd_info.
#func command_test(cmd_info : CommandInfo) -> void:
#	print("A")

#func hello_world(cmd_info : CommandInfo) -> void:
#	$Gift.chat("HELLO WORLD!")

#func streamer_only(cmd_info : CommandInfo) -> void:
#	$Gift.chat("Streamer command executed")

#func greet(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
#	$Gift.chat("Greetings, " + arg_ary[0])

#func join_game(cmd_info : CommandInfo) -> void:
#	$Gift.chat("Greetings, " + cmd_info.sender_data.tags["display-name"] + "! Your ship is waiting for you at the dock.")

#func list(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
#	$Gift.chat(arg_ary.join(", "))

var cell
func sudoku_input(_cmd_info : CommandInfo, args : PackedStringArray) -> void:
	if cell: cell.is_selected = false
	if args.size()<2 and args[0].length()<4:
		return
	var row = int(args[0][1])
	var col = int(args[0][3])
	var nr : int = int(args[1])
	#$Gift.chat("[debug] row: "+str(row)+" col: "+str(col)+" nr: "+str(nr))
	if row<1 or row>9 or col<1 or col>9 or nr<1 or nr>9:
		return
	var cellnr = ((row-1)*9)+(col-1)
	cell = regions.find_child("Cell "+str(cellnr))
	if not cell:
		$Gift.chat("[debug] cell index "+str(cellnr)+" doesn't exist")
		return
	
	cell.is_selected = true
	simulate_keypress(nr)

func simulate_keypress(key):
	print("simulate_keypress: "+str(key))
	var ev = InputEventKey.new()
	ev.keycode = 48+key
	ev.pressed = true
	Input.parse_input_event(ev)

func _on_twitch_connect() -> void:
	match %TwitchConnectButton.text:
		"Connect":
			%ConnectButton.disabled = true
			var success = await($Gift.connect_irc())
			if success:
				%TwitchConnectButton.text = "Disconnect"
				$Gift.chat("You can now play Sudoku. Use: !su rXcY # to send a number # on row(<>) x and column(^v) y.")
				$Gift.chat("Example: !su r1c1 1 will put a 1 in the first small square.")
				%ConnectButton.disabled = false
			else:
				%TwitchConnectButton.text = "Failed"
		"Disconnect":
			%ConnectButton.disabled = true
			$Gift.disconnect_irc()
			%TwitchConnectButton.text = "Connect"
			%ConnectButton.disabled = false
