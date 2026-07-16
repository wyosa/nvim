local function in_helm_chart(path)
	return vim.fs.root(path, "Chart.yaml") ~= nil
end

vim.filetype.add({
	pattern = {
		[".*/%.github/workflows/.*%.ya?ml"] = "yaml.ghaction",
		[".*/%.github/action%.ya?ml"] = "yaml.ghaction",
		[".*/docker%-compose%.ya?ml"] = "yaml.docker-compose",
		[".*/compose%.ya?ml"] = "yaml.docker-compose",
		[".*/templates/.*%.ya?ml"] = function(path)
			return in_helm_chart(path) and "helm" or nil
		end,
		[".*/templates/.*%.tpl"] = function(path)
			return in_helm_chart(path) and "helm" or nil
		end,
		[".*/values[^/]*%.ya?ml"] = function(path)
			return in_helm_chart(path) and "yaml.helm-values" or nil
		end,
	},
})
