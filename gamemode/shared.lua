
hunted = hunted or {}

-- Very core functions go here.
hunted.lib = hunted.lib or {}

-- Scan a directory and include all files in said directories.
-- Credit: https://github.com/jorjic/gmtemplate/blob/master/gamemode/shared.lua

function hunted.lib.includeDir( dir )

	-- Null-coalescing for optional argument
	local isGamemode = false -- ah fuck you this isn't used anymore
	
	local queue = { dir }
	
	-- Loop until queue is cleared
	while #queue > 0 do

		-- For each directory in the queue...
		for _, directory in pairs( queue ) do
			
			local files, directories = file.Find( directory .. "/*", "LUA" )
			
			-- Include files within this directory
			for _, fileName in pairs( files ) do

				if fileName != "shared.lua" and fileName != "init.lua" and fileName != "cl_init.lua" then
					-- print( "Found: ", fileName )
					
					-- Create a relative path for inclusion functions
					-- Also handle pathing case for including gamemode folders
					local relativePath = directory .. "/" .. fileName
					if isGamemode then
						relativePath = string.gsub( directory .. "/" .. fileName, GM.FolderName .. "/gamemode/", "" )
					end
					
					-- Include server files
					if string.match( fileName, "^sv" ) then
						if SERVER then
							include( relativePath )
						end
					end
					
					-- Include shared files
					if string.match( fileName, "^sh" ) then
						AddCSLuaFile( relativePath )
						include( relativePath )
					end
					
					-- Include client files
					if string.match( fileName, "^cl" ) then
						AddCSLuaFile( relativePath )
						
						if CLIENT then
							include( relativePath )
						end
					end
				end
			end
			
			-- Append directories within this directory to the queue
			for _, subdirectory in pairs( directories ) do
				-- print( "Found directory: ", subdirectory )
				table.insert( queue, directory .. "/" .. subdirectory )
			end
			
			-- Remove this directory from the queue
			table.RemoveByValue( queue, directory )

		end

	end

end

function GM:Initialize()
	hunted.lib.includeDir( GM.FolderName .. "/gamemode/lib/" ) -- load the libraries used (currently none)
	hunted.lib.includeDir( GM.FolderName .. "/gamemode/core/" ) -- load the core functions made by me and various contributers if i am lucky.
end