k_ADD = k_ADD or {}
k_ADD.opt = k_ADD.opt or {}
k_ADD.func = k_ADD.func or {}
k_ADD.mod = k_ADD.mod or {}

k_ADD.info = k_ADD.info or {}
k_ADD.info.prefix = "[Kali's Addons]"
k_ADD.info.path = "kali_addons"
k_ADD.info.dataPath = "kali_Addons_Data"

------------------
-- [ Settings ] --
------------------

-- [ Dev ] --

-- [
k_ADD.opt.enable_logging = true
k_ADD.opt.enable_client_log = false
--
k_ADD.opt.logging_Defects = true
k_ADD.opt.logging_Modules = true
k_ADD.opt.logging_Runtime = true
-- ]



-- ]

-----------------------------
-- [ Kali's Custom Print ] --
-----------------------------

k_ADD.func.print = function ( gText, gType )
	if !SERVER && !k_ADD.opt.enable_client_log then return end
	
	if k_ADD.opt.enable_logging then
		gText = gText.."\n"
		if gType == 0 and k_ADD.opt.logging_Runtime then
			MsgC(Color(0,255,0,255),k_ADD.info.prefix.."[Runtime] "..gText)
		end
		if gType == 1 and k_ADD.opt.logging_Modules then
			MsgC(Color(0,0,255,255),k_ADD.info.prefix.."[Modules] "..gText)
		end
		if gType == 2 and k_ADD.opt.logging_Defects then
			MsgC(Color(255,0,0,255),k_ADD.info.prefix.."[Defects] "..gText)
		end
	end
end

kPrint = k_ADD.func.print

---------------------------------
-- [ Kali's Sub-Addon Loader ] --
---------------------------------

k_ADD.func.LoadLua = function ( file, fileT )
	kPrint( "Loading Sub-Addon ["..fileT.."]: "..file, 1 )
	if file and fileT then
		if fileT == "sv" then
			if SERVER then
				include(file)
			end
		elseif fileT == "cl" then
			if SERVER then AddCSLuaFile(file) else include(file) end
		else
			AddCSLuaFile(file)
			include(file)
		end
	end
end

k_ADD.func.LoadLua_Path = function( givenPath )
	kPrint( "Loading Path: "..givenPath, 1 )
	local sv_File, sv_Dir = file.Find( givenPath.."/*", "LUA" )
	for k,v in ipairs(sv_File) do if string.EndsWith(v,".lua") then k_ADD.func.LoadLua(givenPath.."/"..v,string.Left(v,2)) end end
	for k,v in ipairs(sv_Dir) do if v != "Inactive" then k_ADD.func.LoadLua_Path(givenPath.."/"..v) end end
end

-- ]

----------------------------
-- [ Start-up the Addon ] --
----------------------------

kPrint( "Starting-Up", 0 )
k_ADD.func.LoadLua_Path(k_ADD.info.path)
concommand.Add("kReload", function() k_ADD.func.LoadLua_Path(k_ADD.info.path) end)

-- ]

----------------------------
-- [ Start-up the Addon ] --
----------------------------

if SERVER then
	util.AddNetworkString( "kali_ST_CLSV" )
	util.AddNetworkString( "kali_ST_SVCL" )

	k_ADD.func.CheckFile = function(FilePath, FileName)
		FileName = FileName or nil
		kPrint("Checking File: "..FilePath..(FileName or ""), 0)
		
		file.CreateDir( FilePath, "DATA" )

		if FileName then
			if !file.Exists( FilePath.."/"..FileName..".txt", "DATA" ) then
				file.Write( FilePath.."/"..FileName..".txt", "" )
				kPrint( "Creating Missing File: "..FilePath.."/"..FileName..".txt" )
				return false
			else
				return true
			end
		end
	end
	
	k_ADD.func.CheckFile( k_ADD.info.dataPath )
	
	k_ADD.func.ReadFile = function(FilePath, FileName)
		kPrint( "File Read Access: "..FilePath..FileName, 0 )
		doesFileExist = k_ADD.func.CheckFile( k_ADD.info.dataPath.."/"..FilePath, FileName )
		if !doesFileExist then return false end
		return file.Read( k_ADD.info.dataPath.."/"..FilePath.."/"..FileName..".txt" )
	end
	
	kFRead = k_ADD.func.ReadFile
	
	k_ADD.func.WriteFile = function(FilePath, FileName, data)
		kPrint( "File Write Access: "..FilePath..FileName, 0 )
		doesFileExist = k_ADD.func.CheckFile( k_ADD.info.dataPath.."/"..FilePath, FileName )
		if !doesFileExist then return false end
		return file.Write( k_ADD.info.dataPath.."/"..FilePath.."/"..FileName..".txt", data )
	end
	
	kFWrite = k_ADD.func.WriteFile

	util.AddNetworkString( "k_ADD.PlayerLoaded" )
	net.Receive( "k_ADD.PlayerLoaded", function( len, ply ) hook.Call( "k_ADD.HookPlayerLoaded", nil, ply ) end )
	
	function k_ADD.func.NetMSG( Ply, Tbl )
		local TblData = util.Compress( util.TableToJSON(Tbl) )
		kPrint("SV-CL: Sending Data To User", 0)
		
		net.Start( "kali_ST_SVCL" )
		net.WriteUInt( #TblData, 16 )
		net.WriteData( TblData, #TblData )
		net.Send( Ply )
	end
	kNetMSG_sv = k_ADD.func.NetMSG
	
else
	
	function k_ADD.func.NetMSG( Tbl )
		local TblData = util.Compress( util.TableToJSON(Tbl) )
		
		net.Start( "kali_ST_CLSV" )
		net.WriteUInt( #TblData, 16 )
		net.WriteData( TblData, #TblData )
		net.SendToServer()
	end
	kNetMSG_cl = k_ADD.func.NetMSG
	
	hook.Add( "InitPostEntity", "k_ADD.PlayerHasLoadedInCL", function()
		net.Start( "k_ADD.PlayerLoaded" )
		net.SendToServer()
	end )

end

-- ]