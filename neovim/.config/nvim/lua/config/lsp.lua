local map, _ = unpack(require("utils.map"))

map({'i', 's'}, "<Tab>", function ()
	if vim.snippet.active { direction = 1 } then
		return '<cmd>lua vim.snippet.jump(1)<cr>'
	else
		return "<Tab>"
	end
end, { expr = true })

map({'i', 's'}, "<S-Tab>", function ()
	if vim.snippet.active { direction = -1 } then
		return '<cmd>lua vim.snippet.jump(-1)<cr>'
	else
		return "<Tab>"
	end
end, { expr = true })

-- nvim LSP configuration
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions

local navic = require("nvim-navic")

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

	if client.server_capabilities.documentSymbolProvider then
		navic.attach(client, bufnr)
	end

	-- if client.server_capabilities.inlayHintProvider then
	-- 	vim.lsp.inlay_hint(bufnr, true)
	-- end
end

function Inlay_hint()
	vim.lsp.inlay_hint(0, nil)
end


local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
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

lspconfig.ts_ls.setup{
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

-- require("deno-nvim").setup {
-- 	server = {
-- 		on_attach = on_attach,
-- 		capabilities = capabilities,
-- 		cmd = { "deno", "lsp" },
-- 		filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
-- 		root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc")
-- 	}
-- }

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

lspconfig.tinymist.setup {
	on_attach = on_attach,
	capabilities = capabilities,
	offset_encoding = "utf-8",
	settings = {
		exportPdf = "never"
	},
	single_file_support = true
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
