out("common_tommy_lib/debug_try_catch.lua ****************");

local common_tommy_debug_try_catch = {is_debug = true}

function common_tommy_debug_try_catch.catch(what) return what[1] end

function common_tommy_debug_try_catch.try(what)
  if (not _debug.is_debug) then return what[2](result); end
  status, result = pcall(what[1])
  if not status then what[2](result) end
  return result
end

return common_tommy_debug_try_catch
