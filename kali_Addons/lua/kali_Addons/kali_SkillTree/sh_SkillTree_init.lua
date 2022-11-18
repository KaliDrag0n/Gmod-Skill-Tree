k_ADD.mod.ST = k_ADD.mod.ST or {}
k_ADD.mod.ST.data = k_ADD.mod.ST.data or {}
k_ADD.mod.ST.func = k_ADD.mod.ST.func or {}
k_ADD.mod.ST.skills = k_ADD.mod.ST.skills or {}
k_ADD.mod.ST.info = k_ADD.mod.ST.info or {}

k_ADD.mod.ST.info.PData = "Data_SkillTree/"

------------------
-- [ Settings ] --
------------------

-- [ General ] --

if SERVER then
	
	k_ADD.mod.ST.info.PointsPerKill_NPC = 1
	
end

-- [ Dev ] --

concommand.Add( "DispUsers", function() PrintTable( k_ADD.mod.ST.data ) end)
concommand.Add( "ClearUsers", function() k_ADD.mod.ST.data = {} end)
concommand.Add( "ViewSkills", function() PrintTable( k_ADD.mod.ST.skills ) end)
concommand.Add( "ClearSkills", function() k_ADD.mod.ST.skills = {} end)

-- ]

if SERVER then
	concommand.Add( "kGiveP", function()
		k_ADD.mod.ST.data[player.GetAll()[1]:SteamID64()].SkillPoints = 1000
		kNetMSG_sv( player.GetAll()[1], { Task = "kST_LoadPData", Data = k_ADD.mod.ST.data[player.GetAll()[1]:SteamID64()] } )
	end )

	k_ADD.mod.ST.func.LoadPlayerData = function (ply)
		rData = kFRead( k_ADD.mod.ST.info.PData, ply:SteamID64() )
		
		if !rData then
			rData = { SkillPoints = 0, Skills = {} }
			kFWrite( k_ADD.mod.ST.info.PData, ply:SteamID64(), util.TableToJSON( rData ) )
		else
			rData = util.JSONToTable( rData )
		end
		
		kNetMSG_sv( ply, { Task = "kST_LoadPData", Data = rData } )
		k_ADD.mod.ST.data[ ply:SteamID64() ] = rData
	end
	hook.Add( "k_ADD.HookPlayerLoaded", "kali_PlayerHasLoaded", function( ply ) k_ADD.mod.ST.func.LoadPlayerData( ply ) end)
	
	k_ADD.mod.ST.func.SavePlayerData = function (ply)
		kFWrite( k_ADD.mod.ST.info.PData, ply:SteamID64(), util.TableToJSON( k_ADD.mod.ST.data[ ply:SteamID64() ] ) )
		k_ADD.mod.ST.data[ ply:SteamID64() ] = nil
	end
	hook.Add( "PlayerDisconnected", "k_ADD.HookPlayerExited", function( ply ) k_ADD.mod.ST.func.SavePlayerData( ply ) end)
	
	local function custom_JobCheckup( ply )
		kPrint( ply:getJobTable().name, 0 )
		if k_ADD.mod.ST.data[ ply:SteamID64() ].Skills[ ply:getJobTable().name ] == nil then
			kPrint( "Generating Player-Job Data: "..ply:getJobTable().name, 0 )
			k_ADD.mod.ST.data[ ply:SteamID64() ].Skills[ ply:getJobTable().name ] = {
				SkillPoints_Invested = 0,
				SkillsPurchased = {},
				SkillsActivated = {}
			}
		end
		kNetMSG_sv( ply, { Task = "kST_LoadPData", Data = rData } )
	end

	local function custom_HandlePlayerSpawn( ply )
		if k_ADD.mod.ST.data[ply:SteamID64()] != nil then
			custom_JobCheckup( ply )
			
			timer.Create( "AwaitingPlayerSpawnCOMP-"..ply:UserID(), 0, 1, function()
				if k_ADD.mod.ST.data[ply:SteamID64()].Skills[ply:getJobTable().name].SkillsActivated.HP != nil then
					local AddMaxHP = 0
					
					for k, v in pairs(k_ADD.mod.ST.data[ply:SteamID64()].Skills[ply:getJobTable().name].SkillsActivated.HP) do
						for k2, v2 in pairs( v ) do
							if v2 == true then
								local SelSkill = k_ADD.mod.ST.skills.HP[k].IDs[k2]
								if SelSkill.AddHP != nil then AddMaxHP = AddMaxHP + SelSkill.AddHP end
							end
						end
					end
					
					ply:SetMaxHealth( ply:GetMaxHealth() + AddMaxHP )
					ply:SetHealth( ply:GetMaxHealth() )
				end
			end )
		else
			timer.Create( "AwaitPlayerLoadComp-"..ply:UserID(), 0, 1, function() custom_HandlePlayerSpawn( ply ) end )
		end
	end
	
	local function custom_HandleKill( npc, attacker, inflictor )
		if attacker:IsPlayer() then
			if k_ADD.mod.ST.data[attacker:SteamID64()] != nil then
				k_ADD.mod.ST.data[attacker:SteamID64()].SkillPoints = k_ADD.mod.ST.data[attacker:SteamID64()].SkillPoints + k_ADD.mod.ST.info.PointsPerKill_NPC
				attacker:PrintMessage( HUD_PRINTTALK, "You gained "..k_ADD.mod.ST.info.PointsPerKill_NPC.." Skill Point(s)!" )
				kNetMSG_sv( attacker, { Task = "kST_LoadPData", Data = k_ADD.mod.ST.data[attacker:SteamID64()] } )
			end
		end
	end
	
	hook.Add( "OnNPCKilled", "kali_PlayerHasKilled", function( npc, attacker, inflictor ) custom_HandleKill( npc, attacker, inflictor ) end )
	hook.Add( "PlayerChangedTeam", "kali_PlayerHasTeamChanged", function( ply ) timer.Create( "kali_PlayerChangedJob-"..ply:UserID(), 0, 1, function () custom_HandlePlayerSpawn( ply ) end ) end )
	hook.Add( "PlayerSpawn", "kali_PlayerHasSpawned", function( ply ) custom_HandlePlayerSpawn( ply ) end )

	net.Receive( "kali_ST_CLSV", function( len, Ply )
		local TblDecode = net.ReadUInt( 16 )
		local Tbl = util.JSONToTable(util.Decompress(net.ReadData(TblDecode)))
		
		if Tbl.Task == "kST.Equip" then
			local CanStateChange = true
			local UJN = Ply:getJobTable().name
			
			if Tbl.Data.Job != UJN then CanStateChange = false end
			
			if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased[Tbl.Data.Group] == nil && CanStateChange then
				CanStateChange = false
			else
				if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased[Tbl.Data.Group][Tbl.Data.Name] == nil && CanStateChange then
					CanStateChange = false
				else
					if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased[Tbl.Data.Group][Tbl.Data.Name][Tbl.Data.ID] != true && CanStateChange then
						CanStateChange = false
					end
				end
			end
			
			local RetGroupDat = k_ADD.mod.ST.skills[Tbl.Data.Group][Tbl.Data.Name]
			local RetSkillDat = k_ADD.mod.ST.skills[Tbl.Data.Group][Tbl.Data.Name].IDs[Tbl.Data.ID]
			
			if (k_ADD.mod.ST.data[Ply:SteamID64()].SkillPoints - k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillPoints_Invested) < RetSkillDat.Cost && CanBuy then CanBuy = false end
			
			if ((RetGroupDat.AvailableRoles[UJN]) || (RetGroupDat.AvailableRoles["All_Jobs"] && !RetGroupDat.NonAvailableRoles[UJN])) && CanStateChange then
				if (RetSkillDat.AvailableRoles["All_Jobs"] && RetSkillDat.NonAvailableRoles[UJN]) || ((!RetSkillDat.AvailableRoles["All_Jobs"] && !RetSkillDat.AvailableRoles[UJN]) || RetSkillDat.NonAvailableRoles[UJN]) then
					CanStateChange = false
				end
			else
				CanStateChange = false
			end
			
			if CanStateChange then
				if Tbl.Data.Eqp then
					if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsActivated[Tbl.Data.Group] == nil then
						k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsActivated[Tbl.Data.Group] = {}
					end
					
					if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsActivated[Tbl.Data.Group][Tbl.Data.Name] == nil then
						k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsActivated[Tbl.Data.Group][Tbl.Data.Name] = {}
					end
					
					k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsActivated[Tbl.Data.Group][Tbl.Data.Name][Tbl.Data.ID] = true
				else
					if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsActivated[Tbl.Data.Group] != nil then
						if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsActivated[Tbl.Data.Group][Tbl.Data.Name] != nil then
							k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsActivated[Tbl.Data.Group][Tbl.Data.Name][Tbl.Data.ID] = false
						end
					end
				end
				
				kNetMSG_sv( Ply, { Task = "kST_LoadPData", Data = k_ADD.mod.ST.data[Ply:SteamID64()] } )
			end
		end
		
		if Tbl.Task == "kST.Buy" then
			local CanBuy = true
			local UJN = Ply:getJobTable().name
			if Tbl.Data.Job != UJN then CanBuy = false end
			
			if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased[Tbl.Data.Group] != nil && CanBuy then
				if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased[Tbl.Data.Group][Tbl.Data.Name] != nil then
					if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased[Tbl.Data.Group][Tbl.Data.Name][Tbl.Data.ID] == true then
						CanBuy = false
					end
				end
			end
			
			local RetGroupDat = k_ADD.mod.ST.skills[Tbl.Data.Group][Tbl.Data.Name]
			local RetSkillDat = k_ADD.mod.ST.skills[Tbl.Data.Group][Tbl.Data.Name].IDs[Tbl.Data.ID]
			
			if (k_ADD.mod.ST.data[Ply:SteamID64()].SkillPoints - k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillPoints_Invested) < RetSkillDat.Cost && CanBuy then CanBuy = false end
			
			if ((RetGroupDat.AvailableRoles[UJN]) || (RetGroupDat.AvailableRoles["All_Jobs"] && !RetGroupDat.NonAvailableRoles[UJN])) && CanBuy then
				if (RetSkillDat.AvailableRoles["All_Jobs"] && RetSkillDat.NonAvailableRoles[UJN]) || ((!RetSkillDat.AvailableRoles["All_Jobs"] && !RetSkillDat.AvailableRoles[UJN]) || RetSkillDat.NonAvailableRoles[UJN]) then
					CanBuy = false
				end
			else
				CanBuy = false
			end
			
			if CanBuy then
				local pPData = k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased
				local gData = k_ADD.mod.ST.skills[Tbl.Data.Group][Tbl.Data.Name]
				local isRequiredSkillsMet = true
			
				for k, v in pairs(gData.RequiredSkills) do
					if pPData[k] != nil then
						if pPData[k][v.Name] != nil then
							for k2, v2 in pairs( v.IDs ) do
								if pPData[k][v.Name][k2] != true then
									isRequiredSkillsMet = false
									break
								end
							end
						else
							isRequiredSkillsMet = false
							break
						end
					else
						isRequiredSkillsMet = false
						break
					end
				end
			
				if !isRequiredSkillsMet then CanBuy = false end
			end
			
			if CanBuy then
				local pPData = k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased
				local gData = k_ADD.mod.ST.skills[Tbl.Data.Group][Tbl.Data.Name].IDs[Tbl.Data.ID]
				local isRequiredSkillsMet = true
				
				for k, v in pairs(gData.RequiredSkills) do
					if pPData[k] != nil then
						if pPData[k][v.Name] != nil then
							for k2, v2 in pairs( v.IDs ) do
								if pPData[k][v.Name][k2] != true then
									isRequiredSkillsMet = false
									break
								end
							end
						else
							isRequiredSkillsMet = false
							break
						end
					else
						isRequiredSkillsMet = false
						break
					end
				end
			
				if !isRequiredSkillsMet then CanBuy = false end
			end
			
			if CanBuy then
				k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillPoints_Invested = k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillPoints_Invested + k_ADD.mod.ST.skills[Tbl.Data.Group][Tbl.Data.Name].IDs[Tbl.Data.ID].Cost
				
				if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased[Tbl.Data.Group] == nil then
					k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased[Tbl.Data.Group] = {}
				end
				
				if k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased[Tbl.Data.Group][Tbl.Data.Name] == nil then
					k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased[Tbl.Data.Group][Tbl.Data.Name] = {}
				end
				
				k_ADD.mod.ST.data[Ply:SteamID64()].Skills[UJN].SkillsPurchased[Tbl.Data.Group][Tbl.Data.Name][Tbl.Data.ID] = true
				kNetMSG_sv( Ply, { Task = "kST_LoadPData", Data = k_ADD.mod.ST.data[Ply:SteamID64()] } )
			end
		end
	end )

else
	
	net.Receive( "kali_ST_SVCL", function( len, Ply )
		local TblDecode = net.ReadUInt( 16 )
		local Tbl = util.JSONToTable(util.Decompress(net.ReadData(TblDecode)))
		
		if Tbl.Task == "kST_LoadPData" then
			--if IsValid(STUI.P.MF) then STUI.P.MF:Close() end
			LocalPlayer().kST_DAT = Tbl.Data
		end
		
	end )

end

k_ADD.mod.ST.func.AddSkill = function( SkillName, SkillGroup, SkillID, SkillData )
	kPrint( "Skill Added: "..SkillName.." ["..SkillGroup..":"..SkillID.."]", 0 )
	if k_ADD.mod.ST.skills[SkillGroup] == nil then k_ADD.mod.ST.skills[SkillGroup] = {} end
	if k_ADD.mod.ST.skills[SkillGroup][SkillName] == nil then k_ADD.mod.ST.skills[SkillGroup][SkillName] = {} end
	if k_ADD.mod.ST.skills[SkillGroup][SkillName].IDs == nil then k_ADD.mod.ST.skills[SkillGroup][SkillName].IDs = {} end
	k_ADD.mod.ST.skills[SkillGroup][SkillName].IDs[SkillID] = SkillData
end
kAddSkill = k_ADD.mod.ST.func.AddSkill

k_ADD.mod.ST.func.AddSkillGroup = function( SkillName, SkillGroup, SkillGroupData )
	kPrint( "Skill Group Added: "..SkillGroup, 0 )
	if k_ADD.mod.ST.skills[SkillGroup] == nil then k_ADD.mod.ST.skills[SkillGroup] = {} end
	k_ADD.mod.ST.skills[SkillGroup][SkillName] = SkillGroupData
end
kAddSkillGroup = k_ADD.mod.ST.func.AddSkillGroup
