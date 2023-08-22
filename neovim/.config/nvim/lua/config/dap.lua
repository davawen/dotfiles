local dap = require('dap')
dap.adapters.lldb = {
	type = 'executable',
	command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
	name = 'lldb'
}

dap.configurations.cpp = {
	{
		name = 'Launch',
		type = 'lldb',
		request = 'launch',
		program = function()
			return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
		end,
		cwd = '${workspaceFolder}',
		stopOnEntry = false,
		args = { "-h" },
		env = {
			LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES"
		},

		-- 💀
		-- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
		--
		--    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
		--
		-- Otherwise you might get the following error:
		--
		--    Error on launch: Failed to attach to the target process
		--
		-- But you should be aware of the implications:
		-- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
		runInTerminal = false,

		-- 💀
		-- If you use `runInTerminal = true` and resize the terminal window,
		-- lldb-vscode will receive a `SIGWINCH` signal which can cause problems
		-- To avoid that uncomment the following option
		-- See https://github.com/mfussenegger/nvim-dap/issues/236#issuecomment-1066306073
		-- postRunCommands = {'process handle -p true -s false -n false SIGWINCH'}
	},
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

vim.fn.sign_define('DapBreakpoint', { text = '', texthl = '', linehl = '', numhl = '' });
vim.fn.sign_define('DapStopped', { text = '', texthl = '', linehl = '', numhl = '' });


local function attach()
	print("Attaching debugger...")
	dap.run({
		type = 'node2',
		request = 'attach',
		cwd = vim.fn.getcwd(),
		sourceMaps = true,
		protocol = 'inspector',
		skipFiles = { '<node_internals>/**/*.js' }
	})
end

local map, _ = unpack(require('utils.map'))

map('n', '<leader>dh', dap.toggle_breakpoint)
map('n', '<leader>dd', dap.continue) -- start debugger and relaunch execution
map('n', '<leader>da', attach) -- attach debugger to process
map('n', '<leader>dr', function() dap.repl.open({}, 'belowright split') end)
-- map('n', '<leader>di', double_eval)
-- map('v', '<leader>di', double_eval)
map('n', '<leader>d?', function()
	local widgets = require 'dap.ui.widgets'
	widgets.centered_float(widgets.scope)
end)

map('n', '<leader>dk', dap.step_out)
map('n', 'd<S-l>', dap.step_into)
map('n', 'd<S-j>', dap.step_over)
map('n', 'dk', dap.up) -- navigate up/down the callstack
map('n', 'dj', dap.down)
