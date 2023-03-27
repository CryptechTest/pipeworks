local S = minetest.get_translator("pipeworks")
local fs_helpers = pipeworks.fs_helpers

if pipeworks.enable_mese_tube then
	local function update_formspec(pos)
		local meta = minetest.get_meta(pos)
		local old_formspec = meta:get_string("formspec")
		if string.find(old_formspec, "button1") then -- Old version
			local inv = meta:get_inventory()
			for i = 1, 6 do
				for _, stack in ipairs(inv:get_list("line"..i)) do
					minetest.add_item(pos, stack)
				end
			end
		end
		local buttons_formspec = ""
		for i = 0, 5 do
			buttons_formspec = buttons_formspec ..
				"image_button[9,"..(i+(i*0.25)+0.22)..";1,0.5;pipeworks_button_save.png;save;;false;false;pipeworks_button_save_press.png]";
			buttons_formspec = buttons_formspec .. fs_helpers.cycling_button(meta,
				"image_button[9,"..(i+(i*0.25)+0.75)..";1,0.5", "l"..(i+1).."s",
				{
					pipeworks.button_off,
					pipeworks.button_on
				}
			)
		end
		local list_backgrounds = ""
		if minetest.get_modpath("i3") then
			list_backgrounds = "style_type[box;colors=#666]"
			for i=0, 5 do
				for j=0, 5 do
					list_backgrounds = list_backgrounds .. "box[".. 1.5+(i*1.25) .. ",".. 0.25+(j*1.25) ..";1,1;]"
				end
			end
		end
		local field_formspec = ""
		for j = 0, 5 do
			local i = 0
			for i = 0, 2 do
				local deflt = meta:get_string("l"..tostring(j+1).."f"..tostring(i+1))
				field_formspec = field_formspec .. "field_close_on_enter[".. "fs_helpers_input:-:l".. j+1 .."f".. i+1 .. ";false]"
				field_formspec = field_formspec .. "field[".. (i * 2.5)+1.5 ..",".. (j * 1.25)+0.25 ..";2.25,1;fs_helpers_input:-:l".. j+1 .."f".. i+1 ..";;".. deflt .."]"
				i = i + 1
			end
			j =  j + 1
		end

		local size = "10.2,13"
		meta:set_string("formspec",
			"formspec_version[2]"..
			"size["..size.."]"..
			pipeworks.fs_helpers.get_prepends(size)..
			list_backgrounds..
			"image[0.22,0.25;1,1;pipeworks_white.png]"..
			"image[0.22,1.50;1,1;pipeworks_black.png]"..
			"image[0.22,2.75;1,1;pipeworks_green.png]"..
			"image[0.22,4.00;1,1;pipeworks_yellow.png]"..
			"image[0.22,5.25;1,1;pipeworks_blue.png]"..
			"image[0.22,6.50;1,1;pipeworks_red.png]"..
			"style_type[field;font_size=14;textcolor=snow]"..
			field_formspec ..
			--"style_type[label;font_size=16;textcolor=gray]"..
			--"label[0.3,0.75;Pass:]"..
			--"label[0.3,2;Pass:]"..
			--"label[0.3,3.25;Pass:]"..
			--"label[0.3,4.5;Pass:]"..
			--"label[0.3,5.75;Pass:]"..
			--"label[0.3,7;Pass:]"..
			buttons_formspec..
			--"list[current_player;main;0,8;8,4;]" ..
			pipeworks.fs_helpers.get_inv(8)..
			"listring[current_player;main]" ..
			"listring[current_player;main]" ..
			"listring[context;line1]" ..
			"listring[current_player;main]" ..
			"listring[context;line2]" ..
			"listring[current_player;main]" ..
			"listring[context;line3]" ..
			"listring[current_player;main]" ..
			"listring[context;line4]" ..
			"listring[current_player;main]" ..
			"listring[context;line5]" ..
			"listring[current_player;main]" ..
			"listring[context;line6]"
			)
	end

	pipeworks.register_tube("pipeworks:mese_tube3", {
			description = S("Cataloging Pneumatic Tube Segment"),
			inventory_image = "pipeworks_mese_tube_inv_c.png",
			noctr = {"pipeworks_mese_tube_noctr_1_c.png", "pipeworks_mese_tube_noctr_2_c.png", "pipeworks_mese_tube_noctr_3_c.png",
				"pipeworks_mese_tube_noctr_4_c.png", "pipeworks_mese_tube_noctr_5_c.png", "pipeworks_mese_tube_noctr_6_c.png"},
			plain = {"pipeworks_mese_tube_plain_1_c.png", "pipeworks_mese_tube_plain_2_c.png", "pipeworks_mese_tube_plain_3_c.png",
				"pipeworks_mese_tube_plain_4_c.png", "pipeworks_mese_tube_plain_5_c.png", "pipeworks_mese_tube_plain_6_c.png"},
			ends = { "pipeworks_mese_tube_end.png" },
			short = "pipeworks_mese_tube_short_c.png",
			no_facedir = true,  -- Must use old tubes, since the textures are rotated with 6d ones
			node_def = {
				tube = {can_go = function(pos, node, velocity, stack)
						 local tbl, tbln = {}, 0
						 local found, foundn = {}, 0
						 local meta = minetest.get_meta(pos)
						 local inv = meta:get_inventory()
						 local name = stack:get_name()
						 local item = minetest.registered_nodes[name]
						 local groups = {}
						 if (item and item.groups) then
						 	groups = item.groups
						 end
						 local bfound = false;
						 local lastname = "";
						 for i, vect in ipairs(pipeworks.meseadjlist) do
							local npos = vector.add(pos, vect)
							local node = minetest.get_node(npos)
							local reg_node = minetest.registered_nodes[node.name]
							local is_empty = true
							if meta:get_int("l"..i.."s") == 1 and reg_node then
								-- loop over inputs..
								for f = 1, 3 do
									local sname = meta:get_string("l"..i.."f".. f)
									lastname = sname;
									if (sname ~= "" and bfound == false) then 
										is_empty = true;
									end
									local tube_def = reg_node.tube
									if not tube_def or not tube_def.can_insert or
									tube_def.can_insert(npos, node, stack, vect) then
										if sname and sname ~= "" then
											is_empty = false;
										end
										local pattern = ".*"..sname..".*"
										--minetest.log("Found node: " .. string.match(name, "([^:]+)$") .. " pattern: " .. sname)
										for i, g in ipairs(groups) do
											if g and sname ~= "" and g == sname then
												bfound = true;
												foundn = foundn + 1
												found[foundn] = vect
												--minetest.log("Found node Group: " .. g)
												break;
											end
										end
										if (bfound == false and sname ~= "") then
											is_empty = false;
											if (minetest.get_item_group(name, sname) == 1) then	
												bfound = true;
												foundn = foundn + 1
												found[foundn] = vect
												--minetest.log("Found item Group: " .. sname .. " item: " .. name)
											end
											if pattern ~= ".*.*" and string.match(string.match(name, "([^:]+)$"), pattern) then
												bfound = true;
												foundn = foundn + 1
												found[foundn] = vect
												--minetest.log("Found Matching... " .. sname .. " item: " .. name)
											end
										end
										if is_empty then
											tbln = tbln + 1
											tbl[tbln] = vect
										end
									end
									-- break if found
									if (bfound) then
										break
									end
								end
							end
							-- exit port check loop
							if (bfound) then
								--minetest.log("Found Matching.. " .. lastname .. " item: " .. name)
								break
							end
						 end
						 return (foundn > 0) and found or tbl
					end},
				on_construct = function(pos)
					local meta = minetest.get_meta(pos)
					local inv = meta:get_inventory()
					for i = 1, 6 do
						meta:set_int("l"..tostring(i).."s", 1)
						for l = 1, 3 do
							meta:set_string("l"..tostring(i).."f"..tostring(l), "")
						end
					end
					update_formspec(pos)
					meta:set_string("infotext", S("Cataloging filter pneumatic tube"))
				end,
				after_place_node = function(pos, placer, itemstack, pointed_thing)
					if placer and placer:is_player() and placer:get_player_control().aux1 then
						local meta = minetest.get_meta(pos)
						for i = 1, 6 do
							meta:set_int("l"..tostring(i).."s", 0)
							for l = 1, 3 do
								meta:set_string("l"..tostring(i).."f"..tostring(l), "")
							end
						end
						update_formspec(pos)
					end
					return pipeworks.after_place(pos, placer, itemstack, pointed_thing)
				end,
				on_punch = update_formspec,
				on_receive_fields = function(pos, formname, fields, sender)				
					if (fields.quit and not fields.key_enter_field)
							or not pipeworks.may_configure(pos, sender) then
						return
					end
					local meta = minetest.get_meta(pos)					
					for field in pairs(fields) do
						if pipeworks.string_startswith(field, "fs_helpers_input:") then
							--minetest.log(field)
							local l = field:split(":")
							local new_value = fields[field]
							local meta_name = l[3]
							meta:set_string(meta_name, new_value)
						end
					end
					fs_helpers.on_receive_fields(pos, fields)
					update_formspec(pos)
				end,
				can_dig = function(pos, player)
					update_formspec(pos) -- so non-virtual items would be dropped for old tubes
					return true
				end,
			},
	})
end
