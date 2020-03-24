-- lib types for scripting libraries
__lib_type_battle = 0;
__lib_type_campaign = 1;
__lib_type_frontend = 2;

-- store the starting time of this session
lua_start_time = os.clock();

-- gets a timestamp string
function get_timestamp()
	return "<" .. string.format("%.1f", os.clock() - lua_start_time) .. "s>";
end;


-- throw a script error
function script_error(msg, stack_level)
	local ast_line = "********************";
	
	stack_level = stack_level or 0;
	
	-- do output
	print(ast_line);
	print("SCRIPT ERROR, timestamp " .. get_timestamp());
	print(msg);
	print("");
	print(debug.traceback());
	print(ast_line);
	-- assert(false, msg .. "\n" .. debug.traceback());
	
	-- logfile output
	if __write_output_to_logfile then
		local file = io.open(__logfile_path, "a");
		
		if file then
			file:write(ast_line .. "\n");
			file:write("SCRIPT ERROR, timestamp " .. get_timestamp() .. "\n");
			file:write(msg .. "\n");
			file:write("\n");
			file:write(debug.traceback() .. "\n");
			file:write(ast_line .. "\n");
			file:close();
		end;
	end;
end;


-- script logging
__write_output_to_logfile = true;
__logfile_path = "";


if __write_output_to_logfile then
	-- create the logfile
	-- local filename = "script_log_" .. os.date("%d".."".."%m".."".."%y".."_".."%H".."".."%M") .. ".txt";
	local filename = "script_log.txt";
	
	_G.logfile_path = filename;
	
	local file, err_str = io.open(filename, "w");
	
	if not file then
		__write_output_to_logfile = false;
		script_error("ERROR: tried to create logfile with filename " .. filename .. " but operation failed with error: " .. tostring(err_str));
	else
		file:write("\n");
		file:write("creating logfile " .. filename .. "\n");
		file:write("\n");
		file:close();
		__logfile_path = _G.logfile_path;
	end;
end;


-- re-mapping of all output functions so that they support timestamps
function remap_outputs(old_out)
	
	local out = {};
	local output_functions = {};
	
	for key in pairs(old_out) do
		table.insert(output_functions, key);
	end;
	
	-- create a tab level record for each output function, and store it at out.tab_levels
	local tab_levels = {};
	for i = 1, #output_functions do
		tab_levels[output_functions[i]] = 0;
	end;
	tab_levels["out"] = 0;			-- default tab
	out.tab_levels = tab_levels;
		
	-- go through each output function
	for i = 1, #output_functions do
		local current_func_name = output_functions[i];
		
		out[current_func_name] = function(input)		
			input = input or "";
		
			local timestamp = get_timestamp();
			local output_str = timestamp .. string.format("%" .. 11 - string.len(timestamp) .."s", " ");
			
			-- add in all required tab chars
			for i = 1, out["tab_levels"][current_func_name] do
				output_str = output_str .. "\t";
			end;
			
			output_str = output_str .. tostring(input);
			
			old_out[current_func_name](output_str);
			
			-- logfile output
			if __write_output_to_logfile then
				local file = io.open(__logfile_path, "a");
				if file then
					file:write("[" .. current_func_name .. "] " .. output_str .. "\n");
					file:close();
				end;
			end;
		end;
	end;
	
	-- also allow out to be directly called
	
	setmetatable(
		out, 
		{
			__call = function(t, input) 
				input = input or "";
			
				local timestamp = get_timestamp();
				local output_str = timestamp .. string.format("%" .. 11 - string.len(timestamp) .."s", " ");
				
				-- add in all required tab chars
				for i = 1, out.tab_levels["out"] do
					output_str = output_str .. "\t";
				end;
		
				output_str = output_str .. input;
				print(output_str);
				
				-- logfile output
				if __write_output_to_logfile then
					local file = io.open(__logfile_path, "a");
					if file then
						file:write("[out] " .. output_str .. "\n");
						file:close();
					end;
				end;
			end
		}
	);
	
	-- add on functions inc, dec, cache and restore tab levels
	function out.inc_tab(func_name)
		func_name = func_name or "out";
		
		local current_tab_level = out.tab_levels[func_name];
		
		if not current_tab_level then
			script_error("ERROR: inc_tab() called but supplied output function name [" .. tostring(func_name) .. "] not recognised");
			return false;
		end;
		
		out.tab_levels[func_name] = current_tab_level + 1;
	end;
	
	function out.dec_tab(func_name)
		func_name = func_name or "out";
		
		local current_tab_level = out.tab_levels[func_name];
		
		if not current_tab_level then
			script_error("ERROR: dec_tab() called but supplied output function name [" .. tostring(func_name) .. "] not recognised");
			return false;
		end;
		
		if current_tab_level > 0 then
			out.tab_levels[func_name] = current_tab_level - 1;
		end;
	end;
	
	function out.cache_tab(func_name)
		func_name = func_name or "out";
		
		local current_tab_level = out.tab_levels[func_name];
		
		if not current_tab_level then
			script_error("ERROR: cache_tab() called but supplied output function name [" .. tostring(func_name) .. "] not recognised");
			return false;
		end;
		
		-- store cached tab level elsewhere in the tab_levels table
		out.tab_levels["cached_" .. func_name] = current_tab_level;
		out.tab_levels[func_name] = 0;
	end;
	
	function out.restore_tab(func_name)
		func_name = func_name or "out";
		
		local cached_tab_level = out.tab_levels["cached_" .. func_name];
		
		if not cached_tab_level then
			script_error("ERROR: restore_tab() called but could find no cached tab value for supplied output function name [" .. tostring(func_name) .. "]");
			return false;
		end;
		
		-- restore tab level, and clear the cached value
		out.tab_levels[func_name] = cached_tab_level;
		out.tab_levels["cached_" .. func_name] = nil;
	end;
	
	return out;
end;


-- call the remap function so that timestamped output is available immediately (script in other environments will have to re-call it)
out = remap_outputs(out);

-- returns a link to the global events table - a copy of this is stored in _G
function get_events()
	if _G.events then
		return _G.events;
	else
		local events = require "script.events";
		_G.events = events;
		return events;
	end;
end;


-- forceably clears and then requires a file
function force_require(file)
	package.loaded[file] = nil;
	require (file);
end;


-- set up the random seed
math.randomseed(os.time() + os.clock() * 1000);
math.random(); math.random(); math.random(); math.random(); math.random();


-- function to load the script libraries. The __game_mode is set in battle_scripted.lua/campaign_scripted.lua/frontend_scripted.lua
function load_script_libraries()
	-- path to the script folder
	package.path = package.path .. ";data/script/_lib/?.lua";
	
	__script_libraries_loaded = true;

	-- loads in the script library header file, which queries the __game_mode and loads the appropriate library files
	force_require("lib_header");
end;


-- functions to add event callbacks
-- inserts the callback in the events[event] table (the events table being a collection of event tables, each of which contains a list
-- of callbacks to be notified when that event occurs). If a user_defined_list is supplied, then an entry for this event/callback is added
-- to that. This allows areas of the game to clear their listeners out on shutdown (the events table itself is global).
function add_event_callback(event, callback, user_defined_list)
	if type(event) ~= "string" then
		script_error("ERROR: add_event_callback() called but supplied event [" .. tostring(event) .. "] is not a string");
		return false;
	end;
	
	if type(events[event]) ~= "table" then
		events[event] = {};
	end;
	
	if type(callback) ~= "function" then
		script_error("ERROR: add_event_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;

	table.insert(events[event], callback);
	
	-- if we have been supplied a user-defined table, add this event callback to that
	if type(user_defined_list) == "table" then
		local user_defined_event = {};
		user_defined_event.event = event;
		user_defined_event.callback = callback;
		table.insert(user_defined_list, user_defined_event);
	end;
end;


-- function to clear callbacks in the supplied user defined list from the global events table. This can be called by areas of the game
-- when they shutdown.
function clear_event_callbacks(user_defined_list)
	if not type(user_defined_list) == "table" then
		script_error("ERROR: clear_event_callbacks() called but supplied user defined list [" .. tostring(user_defined_list) .. "] is not a table");
		return false;
	end;
	
	local count = 0;

	-- for each entry in the supplied user-defined list, look in the relevant event table
	-- and try to find a matching callback event. If it's there, remove it.
	for i = 1, #user_defined_list do	
		local current_event_name = user_defined_list[i].event;
		local current_event_callback = user_defined_list[i].callback;
		
		for j = 1, #events[current_event_name] do
			if events[current_event_name][j] == current_event_callback then
				count = count + 1;
				table.remove(events[current_event_name], j);
				break;
			end;
		end;
	end;

	-- overwrite the user defined list
	user_defined_list = {};
	
	return count;
end;


-- debug function to print the events table
-- supply a single 'true' argument to print the full table including events that have no listeners (will produce a lot of output)
function print_events_table(full)
	full = not not full;
	
	local ast_line = "**********************";
	print(ast_line);
	print("Printing Events Table: " .. tostring(events));
	print(ast_line);
	
	local count = 0;
	
	for current_event_name, current_event_table in pairs(events) do
		if current_event_name ~= "_NAME" and current_event_name ~= "_PACKAGE" then
			local sizeof_current_event_table = #current_event_table;
			if full or sizeof_current_event_table > 0 then
				if sizeof_current_event_table == 1 then
					print("\tevent " .. current_event_name .. " [" .. tostring(current_event_table) .. "] contains 1 event");
				else
					print("\tevent " .. current_event_name .. " [" .. tostring(current_event_table) .. "] contains " .. sizeof_current_event_table .. " events");
				end;
				
				count = count + 1;
				
				for i = 1, sizeof_current_event_table do
					print("\t\t" .. tostring(current_event_table[i]));
				end;
			end;
		end;
	end;
	print(ast_line);
	if count == 1 then
		print("Listed 1 event");
	else
		print("Listed " .. count .. " events");
	end;
	print(ast_line);
end;


events = get_events();
