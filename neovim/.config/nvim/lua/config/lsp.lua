local lspkind = require("lspkind")
local cmp = require("cmp")

local map, _ = unpack(require("utils.map"))

---@diagnostic disable-next-line: missing-fields
cmp.setup({
	mapping = {
		["<CR>"] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Insert,
			select = false,
		},
		["<S-CR>"] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Insert,
			select = true
		},
		["<C-CR>"] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Insert,
			select = true
		},

		["<c-space>"] = cmp.mapping(function(_)
			if cmp.visible() then
				cmp.close()
			else
				cmp.complete()
			end
		end, { "i", "s" }),

		["<c-J>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),

		["<c-K>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),

		['<C-f>'] = cmp.mapping.scroll_docs(-4),
		['<C-d>'] = cmp.mapping.scroll_docs(4),
		['<C-e>'] = cmp.mapping.abort()
	},
	sources = {
		{ name = "path" },

		{ name = "nvim_lsp" },
		-- { name = "otter" },
		{ name = "snippy" },
		{ name = "buffer", keyword_length = 5 },
	},
	snippet = {
		expand = function(args)
			require('snippy').expand_snippet(args.body)
		end,
	},
	formatting = {
		fields = { "abbr", "kind", "menu" },
		format = lspkind.cmp_format({
			-- max_width = 60,
			mode = "symbol_text",
			menu = {
				buffer = "[buf]",
				nvim_lsp = "[LSP]",
				nvim_lua = "[api]",
				path = "[path]",
				luasnip = "[snip]"
			},
			before = function (entry, vim_item)
				vim_item.menu = "" -- stop weird rust analyzer injecting types into this shit
				return vim_item
			end
		})
	},
	view = {
		entries = { "native" }
	},
	-- window = {
	-- 	completion = cmp.config.window.bordered(),
	-- 	documentation = cmp.config.window.bordered()
	-- },
})

-- nvim LSP configuration
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gq', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	--vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
	--vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
	--vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua require("actions-preview").code_actions()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>=', '<cmd>lua vim.lsp.buf.format{ async = true }<CR>', opts)

	-- if client.server_capabilities.inlayHintProvider then
	-- 	vim.lsp.inlay_hint(bufnr, true)
	-- end
end

function Inlay_hint()
	vim.lsp.inlay_hint(0, nil)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
capabilities = vim.tbl_deep_extend("force", capabilities, {
	workspace = {
		didChangeWatchedFiles = {
			dynamicRegistration = false
		}
	}
})

-- Automatic installation of language servers
require("mason").setup()
require("mason-lspconfig").setup()

local lspconfig = require('lspconfig')

vim.diagnostic.config({
	virtual_text = false,
	underline = true,
	severity_sort = true
})

lspconfig.clangd.setup{
	on_attach = function (client, bufnr)
		on_attach(client, bufnr)
		-- vim.api.nvim_create_autocmd("CursorHoldI", {
		-- 	pattern = "*",
		-- 	callback = function ()
		-- 		if cmp.visible() then
		-- 			cmp.complete()
		-- 		end
		-- 	end,
		-- 	group = augroup
		-- })
	end,
	cmd = {
		"clangd",
		"--background-index",
		"--completion-style=detailed",
		"--header-insertion=never"
	},
	init_options = {
		compilationDatabasePath = "build"
	},
	filetypes = { "c", "cpp", "cuda", "opencl" },
	flags = {
		debounce_text_changes = 150
	},
    root_dir = lspconfig.util.root_pattern("CMakeLists.txt", "Makefile", "xmake.lua", "meson.build"),
	capabilities = capabilities,
}

vim.g.rustaceanvim = {
	-- Plugin configuration
	tools = {

	},
	-- LSP configuration
	server = {
		on_attach = on_attach,
		settings = {
			-- rust-analyzer language server configuration
			['rust-analyzer'] = {
				cachePriming = false
			},
		},
	},
	-- DAP configuration
	dap = {
	},
}

lspconfig.pyright.setup {
	python = {
		analysis = {
			autoSearchPaths = true,
			diagnosticMode = "workspace",
			useLibraryCodeForTypes = true
		}
	},
	on_attach = on_attach,
	capabilities = capabilities
}

lspconfig.cssls.setup {
	on_attach = on_attach,
	capabilities = capabilities
}

lspconfig.html.setup {
	on_attach = on_attach,
	capabilities = capabilities
}

lspconfig.emmet_ls.setup {
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "css", "eruby", "html", "less", "sass", "scss", "svelte", "pug", "vue" }
}

lspconfig.pest_ls.setup {
	on_attach = on_attach,
	capabilities = capabilities
}

lspconfig.tsserver.setup{
	on_attach = on_attach,
	capabilities = capabilities,
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    init_options = {
		hostInfo = "neovim",
		preferences = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
            importModuleSpecifierPreference = 'non-relative'
        }
    },
    root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json"),
	single_file_support = true,
	autostart = false
}

require("deno-nvim").setup {
	server = {
		on_attach = on_attach,
		capabilities = capabilities,
		cmd = { "deno", "lsp" },
		filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
		root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc")
	}
}

lspconfig.ocamllsp.setup {
	on_attach = on_attach,
	capabilities = capabilities,
	single_file_support = true,
	filetypes = vim.list_extend(
		require('lspconfig.server_configurations.ocamllsp').default_config.filetypes,
		{ "ocaml_interface", "ocamllex", "menhir" }
	)
}

lspconfig.svelte.setup{
	on_attach = on_attach,
	capabilities = capabilities,
	root_dir = lspconfig.util.root_pattern("svelte.config.js"),
}

lspconfig.omnisharp.setup{
	on_attach = function (client, bufnr)
		on_attach(client, bufnr)
		client.server_capabilities.semanticTokensProvider = nil
	end,
	filetypes = { "cs", "vb" },
	-- cmd = { "mono", "/home/davawen/.local/bin/omnisharp/OmniSharp.exe" },
	-- Enables support for reading code style, naming convention and analyzer
    -- settings from .editorconfig.
    enable_editorconfig_support = true,

    -- If true, MSBuild project system will only load projects for files that
    -- were opened in the editor. This setting is useful for big C# codebases
    -- and allows for faster initialization of code navigation features only
    -- for projects that are relevant to code that is being edited. With this
    -- setting enabled OmniSharp may load fewer projects and may thus display
    -- incomplete reference lists for symbols.
    enable_ms_build_load_projects_on_demand = false,

    -- Enables support for roslyn analyzers, code fixes and rulesets.
    enable_roslyn_analyzers = false,

    -- Specifies whether 'using' directives should be grouped and sorted during
    -- document formatting.
    organize_imports_on_format = true,

    -- Enables support for showing unimported types and unimported extension
    -- methods in completion lists. When committed, the appropriate using
    -- directive will be added at the top of the current file. This option can
    -- have a negative impact on initial completion responsiveness,
    -- particularly for the first few completion sessions after opening a
    -- solution.
    enable_import_completion = true,

    -- Specifies whether to include preview versions of the .NET SDK when
    -- determining which version to use for project loading.
    sdk_include_prereleases = true,

    -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
    -- true
    analyze_open_documents_only = false,
	root_dir = lspconfig.util.root_pattern('*.sln', '*.csproj'),
	capabilities = capabilities
}

lspconfig.gdscript.setup {
	on_attach = on_attach,
	filetypes = { "gd", "gdscript", "gdscript3" },
	root_dir = lspconfig.util.root_pattern("project.godot", ".git"),
	capabilities = capabilities
}

lspconfig.texlab.setup{
	on_attach = on_attach,
	cmd = { "texlab" },
	filetypes = { "tex", "latex" },
	settings = {
	  texlab = {
		auxDirectory = ".",
		bibtexFormatter = "texlab",
		build = {
		  args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
		  executable = "latexmk",
		  forwardSearchAfter = false,
		  onSave = false
		},
		chktex = {
		  onEdit = false,
		  onOpenAndSave = false
		},
		diagnosticsDelay = 300,
		formatterLineLength = 80,
		forwardSearch = {
		  args = {}
		},
		latexFormatter = "latexindent",
		latexindent = {
		  modifyLineBreaks = false
		}
	  }
	},
	single_file_support = true,
	capabilities = capabilities
}

lspconfig.zls.setup {
	on_attach = on_attach,
	capabilities = capabilities
}

lspconfig.wgsl_analyzer.setup{
	on_attach = on_attach,
	capabilities = capabilities,
}

lspconfig.glsl_analyzer.setup {
	on_attach = on_attach,
	capabilities = capabilities
}

local function sumneko_workspace()
	local library = {
		vim.fn.expand("~/.luarocks/share/lua/5.4"),
		"/usr/share/lua/5.4/",
		vim.fn.expand("~/.config/nvim/lua"),
		vim.fn.expand("~/.config/nvim/after"),
	}

	return library
end

lspconfig.lua_ls.setup {
	before_init = require("neodev.lsp").before_init,
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT',
				pathStrict = false
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				-- globals = {'vim'},
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = sumneko_workspace(),
				checkThirdParty = false
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
			completion = {
				callSnippet = "Replace"
			}
		},
	},
}

lspconfig.gopls.setup{
	on_attach = on_attach,
	capabilities = capabilities
}

lspconfig.julials.setup {
	on_attach = on_attach,
	capabilities = capabilities
}

require('lsp_signature').setup {
	debug = false, -- set to true to enable debug logging
	log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
	-- default is  ~/.cache/nvim/lsp_signature.log
	verbose = false, -- show debug line number

	bind = true, -- This is mandatory, otherwise border config won't get registered.
			   -- If you want to hook lspsaga or other signature handler, pls set to false
	doc_lines = 0, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
				 -- set to 0 if you DO NOT want any API comments be shown
				 -- This setting only take effect in insert mode, it does not affect signature help in normal
				 -- mode, 10 by default

	floating_window = false, -- show hint in a floating window, set to false for virtual text only mode
	floating_window_above_cur_line = false, -- try to place the floating above the current line when possible Note:
	-- will set to true when fully tested, set to false will use whichever side has more space
	-- this setting will be helpful if you do not want the PUM and floating win overlap

	floating_window_off_x = 0, -- adjust float windows x position.
	floating_window_off_y = 0, -- adjust float windows y position.

	fix_pos = false,  -- set to true, the floating window will not auto-close until finish all parameters
	hint_enable = true, -- virtual hint enable
	hint_prefix = "🐼 ",  -- Panda for parameter
	hint_scheme = "String",
	hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
	max_height = 0, -- max height of signature floating_window, if content is more than max_height, you can scroll down
				   -- to view the hiding contents
	max_width = 140, -- max_width of signature floating_window, line will be wrapped if exceed max_width
	handler_opts = {
		border = "rounded"   -- double, rounded, single, shadow, none
	},

	always_trigger = false, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

	auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
	extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
	zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

	padding = '', -- character to pad on left and right of signature can be ' ', or '|'  etc

	transparency = nil, -- disabled by default, allow floating win transparent value 1~100
	shadow_blend = 100, -- if you using shadow as border use this set the opacity
	shadow_guibg = 'Black', -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
	timer_interval = 100, -- default timer check interval set to lower value if you want to reduce latency
	toggle_key = '<M-x>', -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
    select_signature_key = '<M-n>', -- cycle to next signature, e.g. '<M-n>' function overloading
    move_cursor_key = nil, -- imap, use nvim_set_current_win to move cursor between current win and floating
}
