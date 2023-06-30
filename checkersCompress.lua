local function compress(tab)
	local newTab = {}
	for y=1,8 do
		for x=1,8 do
			if y%2 ~= x%2 then
				newTab[#newTab+1] = tab[y][x]
			end
		end

	end
	return newTab
end

local function decompress(tab)
	local newTab = {}
	for y=1,8 do
		newTab[y] = {}
		for x=1,8 do
			newTab[y][x] = y%2 == x%2 and 0 or table.remove(tab,1)
		end
	end
	return newTab
end

local function arrayToEncodedBits(tab)
	local bitBuffer = {}
	local bitBuffer_i = 0

	for i=1,#tab do
		local piece = tab[i]

		if piece == 0 then -- no piece? no problem!
			bitBuffer_i = bitBuffer_i + 1
			bitBuffer[bitBuffer_i] = 0
		else
			bitBuffer[bitBuffer_i + 1] = 1
			bitBuffer[bitBuffer_i + 2] = piece % 2
			bitBuffer[bitBuffer_i + 3] = piece > 2 and 1 or 0
	
			bitBuffer_i = bitBuffer_i + 3
		end
	end

	return bitBuffer
end

local function EncodedBitsToArray(tab)
	local output = {}
	local output_i = 1
	local skips = 0

	for i=1,#tab do
		if skips > 0 then
			skips = skips - 1
			continue
		end
		
		if tab[i] == 0 then
			output[output_i] = 0
			output_i = output_i + 1
		else
			local piece = (tab[i+1] == 0 and 2 or 1) + tab[i+2] * 2
			
			output[output_i] = piece
			output_i = output_i + 1
			skips = 2
		end
	end

	return output
end

local function padArray(tab, factor)
	local pad = #tab % factor -- length % factor = remainder
	if pad == 0 then return tab end -- no padding needed of no remainder

	for i=1,factor-pad do -- factor - remainder = padding needed
		tab[#tab+1] = 0
	end

	return tab
end

local function unpadArray(tab,lengthLimit) -- funny name for "I'm going to remove everything after this"
	for i=lengthLimit+1,#tab do
		tab[i] = nil
	end

	return tab
end

local function encode(tab)
	local output = {}

	for i=1,#tab,8 do
		output[#output+1] = 0
		local output_len = #output
		for j=i,i+7 do
			output[output_len] = output[output_len] + tab[j] * 2^(j-i)
		end
		output[output_len] = string.char(output[output_len])
	end

	return table.concat(output)
end

local function decode(str)
	local output = {}

	for i=1,#str do
		local byte = string.byte(str,i)
		for j=0,7 do
			output[#output+1] = byte % 2
			byte = math.floor(byte/2)
		end
	end

	return output
end

local function orginalToEncoded(tab)
	return encode(padArray(arrayToEncodedBits(compress(tab)),8))
end

--[[
local original = {
	{0,1,0,1,0,1,0,1},
	{1,0,1,0,1,0,1,0},
	{0,1,0,1,0,1,0,1},
	{0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0},
	{2,0,2,0,2,0,2,0},
	{0,2,0,2,0,2,0,2},
	{2,0,2,0,2,0,2,0},
}

local compressed = compress(original)
local encodedBits = arrayToEncodedBits(compressed)
local padded = padArray(encodedBits,8)

local encoded = encode(padded)

local decoded = decode(encoded)
local unpadded = unpadArray(decoded,#encodedBits)
local decompressed = EncodedBitsToArray(unpadded)
local original2 = decompress(decompressed)

do
	local tab = original
	local tab2 = original2

	for k,v in pairs(tab2) do
		for k2,v2 in pairs(v) do
			-- print(k,k2,v2,tab[k][k2],v2 == tab[k][k2])
			if v2 ~= tab[k][k2] then
				print("ERROR")
				break
			end
		end
	end
end

do
	local tab = compressed
	local tab2 = decompressed

	for k,v in pairs(tab2) do
		-- print(k,v,tab[k],v == tab[k])
		if v ~= tab[k] then
			print("ERROR")
			break
		end
	end
end

do
	local tab = encodedBits
	local tab2 = unpadded

	for k,v in pairs(tab2) do
		-- print(k,v,tab[k],v == tab[k])
		if v ~= tab[k] then
			print("ERROR")
			break
		end
	end
end

do
	local tab = padded
	local tab2 = decoded

	for k,v in pairs(tab2) do
		-- print(k,v,tab[k],v == tab[k])
		if v ~= tab[k] then
			print("ERROR")
			break
		end
	end
end
]]