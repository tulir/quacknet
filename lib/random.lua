local characters = {
	"0","1","2","3","4","5","6","7","8","9",
	"a","b","c","d","e","f","g", "h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
	"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
}

function string(len)
	local str=""
	for i=1, len do str = str..characters[math.random(1, #characters)] end
	return str
end

function int(max)
	return math.random(1, max)
end

function float()
	return math.random()
end
