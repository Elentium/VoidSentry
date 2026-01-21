--!native
--!optimize 2

-- [ Services ]
local EncodingService = game:GetService("EncodingService")

-- [ Variables ]
local TypeSigns: { [string | number]: string | number } =
	require("./shared/TypeSigns") :: { [string | number]: string | number }
-- reverse
for name, sign in TypeSigns do
	TypeSigns[sign] = name
end

-- localize
local blen = buffer.len
local b_create = buffer.create

-- init types
local export_type_node = require("./exports/type_node")
local Config = require("./shared/Config")
type typeNode = export_type_node.typeNode

local types: {
	[string]: typeNode | ((...any) -> typeNode),
} = {}
for type: string | number in TypeSigns do
	if typeof(type) == "string" then
		types[type :: string] = require(`./types/{(type :: string):lower()}`)
	end
end

local GetElementType = require("./shared/GetElementType")
local GetElementNode = require("./shared/GetElementNode")
local BuildTypeNode = require("./shared/BuildTypeNode")
local WriteTypeSignsRecursive = require("./shared/WriteTypeSignsRecursive")

-- helper function to calculate size including type signs for nested types
local function CalculateSizeWithTypeSigns(typeNode: typeNode, value: any): number
	local size = 1 -- 1 byte for the type sign itself

	local typeName = typeNode.name
	-- for Enum types, we store the Enum type name (2 bytes length + string length)
	if typeName == "enum" then
		local enumTypeName = tostring(value.EnumType)
		size += 2 + #enumTypeName -- 2 bytes for length, then string bytes
	end

	local bytes = typeNode.bytes
	if typeof(bytes) == "function" then
		size += (bytes :: (value: any) -> number)(value)
	else
		size += bytes :: number
	end

	return size
end

-- [ API ]
local serializer = {}

function serializer.serialize(compressLevel: number?, offset: number?, ...: any): buffer
	-- validation: compression level range check
	if Config.VALIDATION_LEVEL >= 1 then
		if typeof(compressLevel) == "number" and (compressLevel < -7 or compressLevel > 22) then
			error(`Invalid compression level: {compressLevel}. Must be between -7 and 22`)
		end

		-- validation: offset check
		if offset ~= nil and offset < 0 then
			error(`Invalid offset: {offset}. Must be >= 0`)
		end
	end

	local input = table.pack(...)
	local inputCount = input.n
	local writes: { { typeNode: typeNode, value: any } } = table.create(inputCount)
	local totalSize = offset or 0

	for i = 1, inputCount do
		local value = input[i]
		local type = GetElementType(value)
		if type == "unknown" then
			error(`Unknown type detected(unsupported serialization type: {typeof(value)})`)
		end

		local typeModule = types[type]
		local typeNode = GetElementNode(typeModule, value)

		totalSize += CalculateSizeWithTypeSigns(typeNode, value)
		writes[i] = { typeNode = typeNode, value = value }
	end

	local currentOffset = offset or 0
	local b = b_create(totalSize)

	for _, write in writes do
		-- write type signs recursively (including nested types)
		currentOffset = WriteTypeSignsRecursive(b, currentOffset, write.typeNode, write.value, types)
		-- write the actual value data
		currentOffset = write.typeNode.write(b, currentOffset, write.value)
	end

	if typeof(compressLevel) == "number" then
		b = EncodingService:CompressBuffer(b, Enum.CompressionAlgorithm.Zstd, compressLevel)
	end

	return b
end

function serializer.deserialize(compressLevel: number?, offset: number?, b: buffer): ...any
	-- validation: compression level range check
	if Config.VALIDATION_LEVEL >= 1 then
		if typeof(compressLevel) == "number" and (compressLevel < -7 or compressLevel > 22) then
			error(`Invalid compression level: {compressLevel}. Must be between -7 and 22`)
		end

		-- validation: offset check
		if offset ~= nil and offset < 0 then
			error(`Invalid offset: {offset}. Must be >= 0`)
		end
	end

	if typeof(compressLevel) == "number" then
		b = EncodingService:DecompressBuffer(b, Enum.CompressionAlgorithm.Zstd)
	end

	local len = blen(b)
	local currentOffset = offset or 0
	local result = {}
	local resultCount = 0

	while currentOffset < len do
		-- build type node recursively from serialized type signs
		local typeNode: typeNode
		typeNode, currentOffset = BuildTypeNode(b, currentOffset)

		-- read the actual value using the type node
		local val: any
		val, currentOffset = typeNode.read(b, currentOffset)
		resultCount += 1
		result[resultCount] = val
	end

	return table.unpack(result, 1, resultCount)
end

serializer.GetElementType = GetElementType

return serializer
