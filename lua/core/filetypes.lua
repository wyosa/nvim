vim.filetype.add({
	pattern = {
		[".*/%.github/workflows/.*%.ya?ml"] = "yaml.ghaction",
		[".*/%.github/action%.ya?ml"] = "yaml.ghaction",
	},
})
