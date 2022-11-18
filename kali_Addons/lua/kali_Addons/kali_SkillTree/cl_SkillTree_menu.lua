k_ADD_ST_UI = {}
STUI = k_ADD_ST_UI

STUI.P = {}

STUI.D = {}
STUI.D.NodeTree = {}
STUI.D.Delay = false

--PrintTable( k_ADD.mod.ST.skills )

hook.Add( "Think", "kali_SkillTreeMenu", function( ply, key )
	STUI.D.SW = ScrW() * 0.50
	STUI.D.SH = ScrH() * 0.75
	
    if input.IsKeyDown( KEY_F8 ) then
		if !STUI.D.Delay then
			STUI.CheckInvBind()
		else
			timer.Adjust( "kali_ST_EndDelay", 0.125 )
		end
    end
end )

function STUI.CheckInvBind()
	STUI.D.Delay = true
	timer.Create( "kali_ST_EndDelay", 0.125, 1, function() STUI.D.Delay = false end )
	
	if IsValid( STUI.P.MF ) then
		STUI.P.MF:Close()
	else
		if !vgui.CursorVisible() then
			STUI.OpenMenu()
		end
	end
end

STUI.OpenMenu = function()
	UJN = LocalPlayer():getJobTable().name
	
	STUI.P.MF = vgui.Create( "DFrame" )
	STUI.P.MF:SetDraggable(false)
	STUI.P.MF:ShowCloseButton(false)
	STUI.P.MF:SetTitle("")
	STUI.P.MF:SetSize( STUI.D.SW, STUI.D.SH )
	STUI.P.MF:Center()
	STUI.P.MF.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(25,25,25,250)) end
	STUI.P.MF:MakePopup()
	
	STUI.P.MF.MP = vgui.Create( "DPanel", STUI.P.MF )
	STUI.P.MF.MP:SetSize( STUI.D.SW, STUI.D.SH )
	STUI.P.MF.MP.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
	
	STUI.P.MF.TP = vgui.Create( "DPanel", STUI.P.MF.MP )
	STUI.P.MF.TP:Dock( TOP )
	STUI.P.MF.TP:SetHeight( STUI.D.SW * 0.05 )
	STUI.P.MF.TP.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(20,20,25,255)) end
	
	STUI.P.MF.TP.Btn_Cls = vgui.Create( "DButton", STUI.P.MF.TP )
	STUI.P.MF.TP.Btn_Cls:Dock( RIGHT )
	STUI.P.MF.TP.Btn_Cls:SetText( "   Close   " )
	STUI.P.MF.TP.Btn_Cls:SetFont("ScoreboardDefault")
	STUI.P.MF.TP.Btn_Cls:SetColor( Color( 255,255,255,255 ) )
	STUI.P.MF.TP.Btn_Cls:SetContentAlignment(5)
	STUI.P.MF.TP.Btn_Cls:SizeToContents()
	STUI.P.MF.TP.Btn_Cls.DoClick = function() if IsValid(STUI.P.MF) then STUI.P.MF:Close() end end
	STUI.P.MF.TP.Btn_Cls.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
	
	STUI.P.MF.TP.Txt_Title = vgui.Create( "DLabel", STUI.P.MF.TP )
	STUI.P.MF.TP.Txt_Title:Dock( LEFT )
	STUI.P.MF.TP.Txt_Title:SetText( "      [ Skill Tree - By Kali ]" )
	STUI.P.MF.TP.Txt_Title:SetFont("ScoreboardDefault")
	STUI.P.MF.TP.Txt_Title:SetColor( Color( 255,255,255,255 ) )
	STUI.P.MF.TP.Txt_Title:SetContentAlignment(5)
	STUI.P.MF.TP.Txt_Title:SizeToContents()
	STUI.P.MF.TP.Txt_Title.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
	
	STUI.P.MF.TP.Txt_SkillSel = vgui.Create( "DLabel", STUI.P.MF.TP )
	STUI.P.MF.TP.Txt_SkillSel:Dock( FILL )
	STUI.P.MF.TP.Txt_SkillSel:SetText( "" )
	STUI.P.MF.TP.Txt_SkillSel:SetFont("ScoreboardDefault")
	STUI.P.MF.TP.Txt_SkillSel:SetColor( Color( 255,255,255,255 ) )
	STUI.P.MF.TP.Txt_SkillSel:SetContentAlignment(5)
	STUI.P.MF.TP.Txt_SkillSel:SizeToContents()
	STUI.P.MF.TP.Txt_SkillSel.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
	
	STUI.P.MF.LP = vgui.Create( "DPanel", STUI.P.MF.MP )
	STUI.P.MF.LP:Dock( LEFT )
	STUI.P.MF.LP:SetWidth( STUI.D.SW * 0.25 )
	STUI.P.MF.LP.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(20,20,25,255)) end
	
	STUI.P.MF.LP.Txt_Points = vgui.Create( "DLabel", STUI.P.MF.LP )
	STUI.P.MF.LP.Txt_Points:Dock( TOP )
	--STUI.P.MF.LP.Txt_Points:SetText( "   Job: "..UJN.."\n   Points: "..LocalPlayer().kST_DAT.SkillPoints.."\n   ^Spent: "..LocalPlayer().kST_DAT.Skills[UJN].SkillPoints_Invested )
	
	STUI.P.MF.LP.Txt_Points.Think = function()
		STUI.P.MF.LP.Txt_Points:SetText( "   Job: "..UJN.."\n   Points: "..(LocalPlayer().kST_DAT.SkillPoints - LocalPlayer().kST_DAT.Skills[UJN].SkillPoints_Invested) )
		STUI.P.MF.LP.Txt_Points:SizeToContents()
	end
	
	STUI.P.MF.LP.Txt_Points:SetFont("ScoreboardDefault")
	STUI.P.MF.LP.Txt_Points:SetColor( Color( 255,255,255,255 ) )
	STUI.P.MF.LP.Txt_Points:SetContentAlignment(4)
	STUI.P.MF.LP.Txt_Points.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
	
	STUI.P.MF.LP.Txt_Title = vgui.Create( "DLabel", STUI.P.MF.LP )
	STUI.P.MF.LP.Txt_Title:Dock( TOP )
	STUI.P.MF.LP.Txt_Title:SetText( "[ Skills ]" )
	STUI.P.MF.LP.Txt_Title:SetFont("ScoreboardDefault")
	STUI.P.MF.LP.Txt_Title:SetColor( Color( 255,255,255,255 ) )
	STUI.P.MF.LP.Txt_Title:SetContentAlignment(5)
	STUI.P.MF.LP.Txt_Title:SizeToContents()
	STUI.P.MF.LP.Txt_Title.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
	
	STUI.P.MF.LP.Scroll_Skills = vgui.Create( "DScrollPanel", STUI.P.MF.LP )
	STUI.P.MF.LP.Scroll_Skills:Dock( FILL )
	
	local _SkillGroup_Height = STUI.D.SH * 0.05
	for k, v in pairs( k_ADD.mod.ST.skills ) do
		local _SkillGroup = STUI.P.MF.LP.Scroll_Skills:Add( "DButton" )
		_SkillGroup:Dock( TOP )
		_SkillGroup:SetHeight( _SkillGroup_Height )
		_SkillGroup:SetFont("ScoreboardDefault")
		_SkillGroup:SetText(k)
		_SkillGroup:SetColor( Color( 200, 65, 65, 255 ) )
		_SkillGroup.DoClick = function() STUI.GenTree(k) end
		_SkillGroup.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
	end
	
	STUI.P.MF.CP = vgui.Create( "DPanel", STUI.P.MF.MP )
	STUI.P.MF.CP:Dock( FILL )
	STUI.P.MF.CP.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
end

STUI.GenTree = function( SkillGroup )
	STUI.P.MF.TP.Txt_SkillSel:SetText( "Selected Skill Group : "..SkillGroup )
	STUI.P.MF.CP:Clear()
	
	sInfo = vgui.Create( "DPanel", STUI.P.MF.CP )
	sInfo:Dock( BOTTOM )
	sInfo:SetHeight( STUI.D.SH * 0.1 )
	sInfo.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(15,15,20,255)) end
	
	local dtree = vgui.Create( "DTree", STUI.P.MF.CP )
	dtree:Dock( FILL )
	dtree.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
	
	for k, v in pairs( k_ADD.mod.ST.skills[SkillGroup] ) do --Core Skills
		if (v.AvailableRoles[UJN]) || (v.AvailableRoles["All_Jobs"] && !v.NonAvailableRoles[UJN]) then
			STUI.D.NodeTree[k] = dtree:AddNode( v.DispName )
			STUI.D.NodeTree[k].Label:SetColor( Color(255,255,255,255) )
			STUI.D.NodeTree[k].Label:SetFont("CenterPrintText")
			
			STUI.D.NodeTree[k]["Desc"] = STUI.D.NodeTree[k]:AddNode( v.Desc, "icon16/book.png" )
			STUI.D.NodeTree[k]["Desc"].Label:SetColor( Color(255,255,255,255) )
			STUI.D.NodeTree[k]["Desc"].Label:SetFont("CenterPrintText")
			
			for k2, v2 in pairs( k_ADD.mod.ST.skills[SkillGroup][k].IDs ) do
				if (v2.AvailableRoles[UJN]) || (v2.AvailableRoles["All_Jobs"] && !v2.NonAvailableRoles[UJN])  then
					STUI.D.NodeTree[k][k2] = STUI.D.NodeTree[k]:AddNode( v2.DispName, "icon16/cross.png" )
					
					STUI.D.NodeTree[k][k2].Think = function()
						local ShouldEquip = false
						
						if LocalPlayer().kST_DAT.Skills[UJN].SkillsPurchased[SkillGroup] != nil then
							if LocalPlayer().kST_DAT.Skills[UJN].SkillsPurchased[SkillGroup][k] != nil then
								if LocalPlayer().kST_DAT.Skills[UJN].SkillsPurchased[SkillGroup][k][k2] == true then
									STUI.D.NodeTree[k][k2]:SetIcon( "icon16/tick.png" )
									ShouldEquip = true
									local ShouldDisp = false
									
									if LocalPlayer().kST_DAT.Skills[UJN].SkillsActivated[SkillGroup] != nil then
										if LocalPlayer().kST_DAT.Skills[UJN].SkillsActivated[SkillGroup][k] != nil then
											if LocalPlayer().kST_DAT.Skills[UJN].SkillsActivated[SkillGroup][k][k2] == true then
												STUI.D.NodeTree[k][k2].Label:SetText( v2.DispName.."[EQUIPPED]" )
												ShouldDisp = true
											end
										end
									end
									
									if !ShouldDisp then
										STUI.D.NodeTree[k][k2].Label:SetText( v2.DispName.."[UN-EQUIPPED]" )
									end
								end
							end
						end
						
						if !ShouldEquip then
							STUI.D.NodeTree[k][k2]:SetIcon( "icon16/cross.png" )
						end
					end
					
					STUI.D.NodeTree[k][k2].DoClick = function() STUI.GenData( SkillGroup, k, k2, v2, sInfo ) end
					STUI.D.NodeTree[k][k2].Label:SetColor( Color(255,255,255,255) )
					STUI.D.NodeTree[k][k2].Label:SetFont("CenterPrintText")
				end
			end
		end
	end
end

STUI.GenData = function( group, group_id, skill_id, gData, iPanel )
	iPanel:Clear()
	local isSkillEmpty = true
	
	iPanel.LP = vgui.Create( "DPanel", iPanel )
	iPanel.LP:Dock( LEFT )
	iPanel.LP:SetWide( iPanel:GetWide() * 0.25 )
	iPanel.LP.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
	
	iPanel.Btn_Main = vgui.Create( "DButton", iPanel.LP )
	iPanel.Btn_Main:Dock( FILL )
	iPanel.Btn_Main:SetFont("CenterPrintText")
	iPanel.Btn_Main:SetColor( Color(255,255,255,255) )
	iPanel.Btn_Main.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
	
	if LocalPlayer().kST_DAT.Skills[UJN].SkillsPurchased[group] != nil then
		if LocalPlayer().kST_DAT.Skills[UJN].SkillsPurchased[group][group_id] != nil then
			if LocalPlayer().kST_DAT.Skills[UJN].SkillsPurchased[group][group_id][skill_id] == true then
				isSkillEmpty = false
			end
		end
	end
	
	if isSkillEmpty then
		local CanPurchaseSkill = true
		
		if gData.RequiredSkills != nil then
			local isRequiredSkillsMet = true
			local theRequiredSkill = {}
			
			for k, v in pairs(gData.RequiredSkills) do
				theRequiredSkill.Name = k
				theRequiredSkill.Data = v
				
				if LocalPlayer().kST_DAT.Skills[UJN].SkillsPurchased[k] != nil then
					if LocalPlayer().kST_DAT.Skills[UJN].SkillsPurchased[k][v.Name] != nil then
						for k2, v2 in pairs( v.IDs ) do
							if LocalPlayer().kST_DAT.Skills[UJN].SkillsPurchased[k][v.Name][k2] != true then
								theRequiredSkill.ID = k2
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
			
			if !isRequiredSkillsMet then
				CanPurchaseSkill = false
				
				iPanel.Btn_Main:SetColor( Color(255,0,0,255) )
				iPanel.Btn_Main:Dock( TOP )
				iPanel.Btn_Main:SetHeight( STUI.D.SH * 0.05 )
				
				iPanel.Txt_Req = vgui.Create( "DLabel", iPanel.LP )
				iPanel.Txt_Req:Dock( FILL )
				
				local SR_Call = k_ADD.mod.ST.skills[theRequiredSkill.Name][theRequiredSkill.Data.Name].IDs[ (theRequiredSkill.ID || table.GetKeys(theRequiredSkill.Data.IDs)[1]) ]
				iPanel.Txt_Req:SetText( "Skill Required:\n"..theRequiredSkill.Name.." - "..SR_Call.DispName )
				
				iPanel.Txt_Req:SetContentAlignment(4)
				iPanel.Txt_Req:SetColor( Color(255,255,255,255) )
				iPanel.Txt_Req:SetFont("CenterPrintText")
				iPanel.Txt_Req.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
			end
			
			iPanel.Txt_Cost = vgui.Create( "DLabel", iPanel )
			iPanel.Txt_Cost:Dock( RIGHT )
			iPanel.Txt_Cost:SetWide( iPanel:GetWide() * 0.25 )
			iPanel.Txt_Cost:SetFont("CenterPrintText")
			iPanel.Txt_Cost:SetText( "Cost: "..gData.Cost.."\nSkill Points" )
			iPanel.Txt_Cost:SetContentAlignment(5)
		end
		
		iPanel.Btn_Main:SetText( "Purchase" )
		iPanel.Btn_Main.DoClick = function() kNetMSG_cl( { Task = "kST.Buy", Data = { Group=group, Name=group_id, ID=skill_id, Job=UJN } } ) iPanel:Clear() end
		PrintTable( { Task = "kST.Buy", Data = { Group=group, Name=group_id, ID=skill_id } } )
	else
		local EquipStatus = true
		
		if LocalPlayer().kST_DAT.Skills[UJN].SkillsActivated[group] != nil then
			if LocalPlayer().kST_DAT.Skills[UJN].SkillsActivated[group][group_id] != nil then
				if LocalPlayer().kST_DAT.Skills[UJN].SkillsActivated[group][group_id][skill_id] == true then
					EquipStatus = false
				end
			end
		end
		
		if EquipStatus then
			iPanel.Btn_Main:SetText( "Equip" )
		else
			iPanel.Btn_Main:SetText( "Un-Equip" )
		end
		
		iPanel.Btn_Main.DoClick = function() kNetMSG_cl( { Task = "kST.Equip", Data = { Group=group, Name=group_id, ID=skill_id, Job=UJN, Eqp=EquipStatus } } ) iPanel:Clear() end
	end
	
	iPanel.MP = vgui.Create( "DPanel", iPanel )
	iPanel.MP:Dock( LEFT )
	iPanel.MP:SetWide( iPanel:GetWide() * 0.5 )
	iPanel.MP.Paint = function(s,w,h) draw.RoundedBox(0,0,0,w,h,Color(25,25,25,255)) end
		
	iPanel.MP.Title = vgui.Create( "DLabel", iPanel.MP )
	iPanel.MP.Title:Dock( TOP )
	iPanel.MP.Title:SetHeight( STUI.D.SH * 0.05 )
	iPanel.MP.Title:SetFont("CenterPrintText")
	iPanel.MP.Title:SetText( gData.DispName )
	iPanel.MP.Title:SetContentAlignment(5)
		
	iPanel.MP.Desc = vgui.Create( "DLabel", iPanel.MP )
	iPanel.MP.Desc:Dock( BOTTOM )
	iPanel.MP.Desc:SetHeight( STUI.D.SH * 0.05 )
	iPanel.MP.Desc:SetFont("CenterPrintText")
	iPanel.MP.Desc:SetText( gData.Desc )
	iPanel.MP.Desc:SetContentAlignment(5)

end