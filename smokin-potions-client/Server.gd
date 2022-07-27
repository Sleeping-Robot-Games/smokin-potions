extends Node

var network = NetworkedMultiplayerENet.new()
var ip = '127.0.0.1' # Home address for debuggin locally
#var ip = '' actual IP address for testing
var port = 1909

func _ready():
	pass
	
func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionFailed():
	print('Failed to connect')
	
	
func _OnConnectionSucceeded():
	print('Successfully connected')
