NAT_create_healer_menu_controller = 
function(_postOptionObject, _postLabel, _viewBody)
	local controller = NAT_create_menu_controller(_postOptionObject, _postLabel, _viewBody);
	controller.tag = "Healer";
	controller.toggle_command = "toggle_healer-"; --network
	controller.add_player_command = "add_healer"; --observer command 
	controller.remove_player_command = "remove_healer"; --observer command
	controller.current_focus_mark = "";
	controller.current_menu_parent = nil;
	controller.assigned_players = {["Raid"]={}};
	controller.marks = {[1]="Raid"};
	controller.useable_classes = {"Priest", "Paladin", "Druid", "Shaman"}
	
	--FUNCTIONS-------------------------------------------------------------------------------------------------------F
	--function to setup tank list
	controller.init =
	function(self)
		UIDROPDOWNMENU_SHOW_TIME  = 0;

		--create layer 2 information
		local create_sub_info =  
		function(name, color)
			local info = {};
		   info.hasArrow = false; -- no submenus this time
		   info.text = color..name;
		   info.value =  name;
		   info.func = 
		   function() 
				--check if addon is ready 
				if not NAT_is_ready()
				then 
					DEFAULT_CHAT_FRAME:AddMessage("NAT: You are not setup yet. Wait for the go ahead or try to setup again. (Master might be offline)", 0.6,1.0,0.6);
					return;
				end
		   
				--check if i have permission to make changes
				if not IsRaidLeader() and not IsRaidOfficer()
				then
					--no permission, exit
					DEFAULT_CHAT_FRAME:AddMessage("NAT: You need to be the raid leader OR have assist to make changes", 0.6,1.0,0.6);
					return;
				end
		   
				--check if its setup
				if controller.current_focus_mark == ""
				then
					return;
				end
				
				if controller.assigned_players[controller.current_focus_mark] == nil
				then
					return;
				end
				
				--Am I in the list already? 
				for entry, list_name in ipairs(controller.assigned_players[controller.current_focus_mark])
				do
					if info.text == list_name
					then
						--remove from list
						table.remove(controller.assigned_players[controller.current_focus_mark], entry);
						local tmark = controller.current_focus_mark
						if controller.current_focus_mark ~= "Raid"
						then
							tmark = string.sub(controller.current_focus_mark, 11, strlen(controller.current_focus_mark));
						end
						
						SendAddonMessage("NAT", controller.toggle_command..tmark..":"..string.sub(info.text, 11, strlen(info.text)).."-"..UnitName("player"), "RAID")
						controller.update_marks();
						return;
					end
				end
				
				local tmark = controller.current_focus_mark
				if controller.current_focus_mark ~= "Raid"
				then
					tmark = string.sub(controller.current_focus_mark, 11, strlen(controller.current_focus_mark));
				end
				
				--add to list
				table.insert(controller.assigned_players[controller.current_focus_mark], info.text);
				SendAddonMessage("NAT", controller.toggle_command..tmark..":"..string.sub(info.text, 11, strlen(info.text)).."-"..UnitName("player"), "RAID")
				controller.update_marks();
				
			end
			
			return info;
		end

		if UIDROPDOWNMENU_MENU_LEVEL== 1
		then
			local title = {};
			title.text = "players"
			title.isTitle = true;
			UIDropDownMenu_AddButton(title,1);
			
			
			local index = 1;
			for index, class_name in ipairs(controller.useable_classes)
			do
				local class = {};
				class.text = NAT_retrieve_class_color(class_name)..class_name;
				class.value = index;
				class.hasArrow = true;
				class.func = function() end;
				
				if table.getn(controller.available_players[class_name]) == 0
				then
					class.disabled = true;
					class.hasArrow = false;
					class.text = "|cff545454"..class_name
				end
				UIDropDownMenu_AddButton(class, 1);
			end
			
			local clear = {}
			clear.text = "|cffFF0000Clear";
			clear.value = index+1;
			clear.hasArrow = false;
			clear.func = 
			function() 
				if not IsRaidLeader() and not IsRaidOfficer()
				then
					DEFAULT_CHAT_FRAME:AddMessage("NAT: Can not use clear function without being the raid leader or having assist.", 0.6,1.0,0.6);
					return;
				end
			
				controller.clear_mark(controller.current_focus_mark);
			end
			UIDropDownMenu_AddButton(clear, 1)
		elseif UIDROPDOWNMENU_MENU_LEVEL == 2
		then
			local title = {};
			title.text = controller.tag;
			title.isTitle = true;
			UIDropDownMenu_AddButton(title, 2);
		
			for i, class_name in ipairs(controller.useable_classes)
			do
				if UIDROPDOWNMENU_MENU_VALUE == i
				then
					for _, name in ipairs(controller.available_players[class_name])
					do
					   UIDropDownMenu_AddButton(create_sub_info(name, NAT_retrieve_class_color(class_name)), 2);
					end
					break;
				end
			end
		end
	end

	
	controller.add_tank = 
	function(ntank)
		--check if tank already exists
		for _, tank in ipairs(controller.marks)
		do
			--already exists
			if tank == ntank
			then 
				return;
			end
		end 
		
		--add them to list
		table.insert(controller.marks, ntank);
		controller.assigned_players[ntank] = {};
		controller.update_assigned_tank_labels();
	end
	
	controller.remove_tank = 
	function(tank)
		for index, atank in ipairs(controller.marks)
		do
			--found
			if tank == atank
			then
				--remove from assignment list
				controller.assigned_players[atank] = nil;
				
				--remove from this list
				table.remove(controller.marks, index);
				
				--update views
				controller.update_assigned_tank_labels();
				
				break;
			end
		end
	end
	
	
	controller.update_assigned_tank_labels = 
	function()
		--setup label names
			--shity work around because retrieving frames from primary frame is aids
		for i,tank in ipairs(controller.marks)
		do
			if i == 1
			then 
				tank1_label:SetText(tank);
			elseif i == 2
			then
				tank2_label:SetText(tank);
			elseif i == 3
			then
				tank3_label:SetText(tank);
			elseif i == 4
			then 
				tank4_label:SetText(tank);
			elseif i == 5
			then 
				tank5_label:SetText(tank);
			elseif i == 6
			then 
				tank6_label:SetText(tank);
			elseif i == 7
			then 
				tank7_label:SetText(tank);
			elseif i == 8
			then 
				tank8_label:SetText(tank);
			elseif i == 9
			then 
				tank9_label:SetText(tank);
			end
		end
		
		for i=9, table.getn(controller.marks)+1, -1
		do
			if i == 1
			then 
				tank1_label:SetText("");
			elseif i == 2
			then
				tank2_label:SetText("");
			elseif i == 3
			then
				tank3_label:SetText("");
			elseif i == 4
			then 
				tank4_label:SetText("");
			elseif i == 5
			then 
				tank5_label:SetText("");
			elseif i == 6
			then 
				tank6_label:SetText("");
			elseif i == 7
			then 
				tank7_label:SetText("");
			elseif i == 8
			then 
				tank8_label:SetText("");
			elseif i == 9
			then
				tank9_label:SetText("");
			end
			
			--hide frames from removed tanks
			for _, healer_frame in ipairs(controller.NAT_assignment_frames[i])
			do
				healer_frame:Hide();
			end
		end
		controller.update_marks();
	end
	
	controller.interpret_notification = 
	function(action, _arglist)
		if action == "add_tank"
		then
			if _arglist == nil
			then
				return;
			end 
			controller.add_tank(_arglist[1]);
		elseif action == "remove_tank"
		then
			if _arglist == nil
			then
				return;
			end 
		
			controller.remove_tank(_arglist[1]);
		end
	end
	
	controller.clean_mark = 
	function(_mark_text)
		SendChatMessage(_mark_text, "WHISPER", "COMMON", UnitName("Player"));
	
		if _mark_text == "Raid"
		then
			return _mark_text;
		end
	
		return string.sub(_mark_text,  11, strlen(_mark_text));
	end
	--FUNCTIONS-------------------------------------------------------------------------------------------------------F
	
	return controller;
end 