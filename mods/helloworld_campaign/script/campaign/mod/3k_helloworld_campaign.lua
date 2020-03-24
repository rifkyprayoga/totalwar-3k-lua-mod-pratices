__write_output_to_logfile = true; --- <--- 记得在发布时注释掉
__logfile_path = "script_log.txt"; --- <--- 记得在发布时注释掉

out("my_mod | 3k_helloworld.lua hello world"); -- MOD文件加载时会调用此lua文件

local _debug = {is_debug = true} -- local 调试变量，避免影响全局，其他mod

function _debug:catch(what) return what[1] end

function _debug:try(what)
  if (not _debug.is_debug) then return what[2](result); end
  status, result = pcall(what[1])
  if not status then what[2](result) end
  return result
end

local function hello_world()
  -- 在这实现mod功能
  out("my_mod | first_tick_callback hello world!");
  out(xxx); --<-- 报错引用未定义xxx变量
end

local function RUN_hello_world() -- 游戏初始化时会调用函数
  _debug:try {
    function()
      hello_world() -- 用try catch将整个mod函数体实现包裹起来
    end,
    _debug:catch{function(error) script_error('my_mod | CAUGHT ERROR: ' .. error); end}
  }
end

-- 添加游戏初始化的回调，执行 RUN_hello_world 函数
cm:add_first_tick_callback(function(context) RUN_hello_world(context) end);
