--!native
--!optimize 2
--!strict
-- [ Services ]
local EncodingService = game:GetService("EncodingService")

-- [ Variables ]
local export_type_node = require("./exports/type_node")
local Config = require("./shared/Config")

type TypeNode = export_type_node.typeNode

-- localize
local b_create = buffer.create

-- [ API ]
local serializer = {}
serializer.__index = serializer
function serializer.new(compressionLevel: number?, ...: TypeNode)
	local self = setmetatable({}, serializer)
	self.schema = { ... }

	-- validation: compression level range check
	if Config.VALIDATION_LEVEL >= 1 then
		if typeof(compressionLevel) == "number" and (compressionLevel < -7 or compressionLevel > 22) then
			error(`Invalid compression level: {compressionLevel}. Must be between -7 and 22`)
		end
	end

	self.compressionLevel = compressionLevel
	return self
end

function serializer:serialize(offset: number?, ...: any): buffer
	local input = table.pack(...)
	local schema: { TypeNode } = self.schema

	if Config.VALIDATION_LEVEL >= 1 then
		local inputCount = input.n
		local schemaCount = #schema

		if inputCount < schemaCount then
			local trailingAllowedCount = 0
			for i = schemaCount, inputCount + 1, -1 do
				local node = schema[i]
				if node and (node.name == "optional" or node.name == "nil") then
					trailingAllowedCount += 1
				else
					break
				end
			end

			if inputCount + trailingAllowedCount < schemaCount then
				error(`Schema mismatch: expected {schemaCount} values, got {inputCount}`)
			end
		elseif inputCount > schemaCount then
			error(`Schema mismatch: expected {schemaCount} values, got {inputCount}`)
		end

		if offset ~= nil and offset < 0 then
			error(`Invalid offset: {offset}. Must be >= 0`)
		end
	end

	local size = offset or 0
	for i, node: TypeNode in schema do
		local value = input[i] -- will be nil if not provided, which is fine for optional types
		size += (typeof(node.bytes) == "function" and (node.bytes :: (value: any) -> number)(value) or node.bytes :: number)
	end

	local b = b_create(size)
	offset = offset or 0
	for i, node: TypeNode in schema do
		local value = input[i] -- will be nil if not provided, which is fine for optional types
		offset = node.write(b, offset :: number, value)
	end
	if typeof(self.compressionLevel) == "number" then
		b = EncodingService:CompressBuffer(b, Enum.CompressionAlgorithm.Zstd, self.compressionLevel)
	end

	return b
end

function serializer:deserialize(offset: number?, b: buffer): ...any
	-- validation: offset check
	if Config.VALIDATION_LEVEL >= 1 then
		if offset ~= nil and offset < 0 then
			error(`Invalid offset: {offset}. Must be >= 0`)
		end
	end

	if typeof(self.compressionLevel) == "number" then
		b = EncodingService:DecompressBuffer(b, Enum.CompressionAlgorithm.Zstd)
	end

	local schema: { TypeNode } = self.schema
	local schemaCount = #schema
	local result = table.create(schemaCount)
	offset = offset or 0
	for i = 1, schemaCount do
		local node = schema[i]
		result[i], offset = node.read(b, offset :: number)
	end

	return table.unpack(result, 1, schemaCount)
end

return serializer
