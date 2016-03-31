

var small = 0.5
var medium = 1.0
var big = 1.5

#random weights do not need to add to 100
#length is in centimeters, average size
#weight : fish(name, energy, shadowsize, reaction, length, icon)
var fish_types = [
	{weight = 15, name = "Archerfish", energy = 140, shadowsize = big, reaction = 0.6, length = 20, icon = "archerfish"},
	{weight = 40, name = "Bitterling", energy = 100, shadowsize = small, reaction = 1, length = 10, icon = "bitterling"},
	{weight = 20, name = "Crawfish", energy = 150, shadowsize = medium, reaction = 0.5, length = 15, icon = "crawfish"},
	{weight = 65, name = "Fathead Minnow", energy = 80, shadowsize = small, reaction = 0.8, length = 5, icon = "fathead_minnow"},
	{weight = 20, name = "Freshwater Goby", energy = 180, shadowsize = big, reaction = 0.5, length = 15, icon = "freshwater_goby"},
	{weight = 10, name = "Frog", energy = 200, shadowsize = big, reaction = 0.35, length = 15, icon = "frog"},
	{weight = 60, name = "Goldfish", energy = 80, shadowsize = medium, reaction = 1.2, length = 12, icon = "goldfish"},
	{weight = 70, name = "Guppy", energy = 60, shadowsize = small, reaction = 1.5, length = 3, icon = "guppy"},
	{weight = 50, name = "Killifish", energy = 110, shadowsize = small, reaction = 1, length = 4, icon = "killifish"},
	{weight = 40, name = "Neon Tetra", energy = 80, shadowsize = small, reaction = 0.8, length = 3, icon = "neon_tetra"},
	{weight = 30, name = "Nibble Fish", energy = 100, shadowsize = small, reaction = 0.6, length = 5, icon = "nibble_fish"},
	{weight = 40, name = "Pale Chub", energy = 130, shadowsize = big, reaction = 0.6, length = 18, icon = "pale_chub"},
	{weight = 50, name = "Pond Smelt", energy = 100, shadowsize = medium, reaction = 1, length = 14, icon = "pond_smelt"},
	{weight = 30, name = "Tadpole", energy = 100, shadowsize = small, reaction = 1, length = 10, icon = "tadpole"}
]

func lookup_value(table, x):
	#find the value in the table that corrisponds with x
	var cumulative_weight = 0
	for i in range(table.size()):
		var weight = table[i]["weight"]
		cumulative_weight += weight
		if x <= cumulative_weight:
			return table[i]


func random_fish():
	#get random value from a table of weights
	var table = fish_types
	var sum_of_weights = 0
	for i in range(table.size()):
		var weight = table[i]["weight"]
		sum_of_weights += weight
	
	var x = sum_of_weights * randf()
	return lookup_value(table, x)


