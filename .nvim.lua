require("lspconfig")["elixirls"].setup({
	capabilities = vim.lspconfig.capabilities,
	on_attach = vim.lspconfig.on_attach,
	cmd = {"elixir-ls"}
})
