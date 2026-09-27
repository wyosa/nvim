-- Distinguish plain YAML from Compose, GitHub Actions, GitLab and Helm.

local function in_helm_chart(path)
	return vim.fs.root(path, "Chart.yaml") ~= nil
end

vim.filetype.add({
	pattern = {
		[".*/%.github/workflows/.*%.ya?ml"] = { "yaml.ghaction", { priority = 10 } },
		[".*/action%.ya?ml"] = "yaml.github-action",
		[".*/%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
		[".*/docker%-compose%.ya?ml"] = "yaml.docker-compose",
		[".*/docker%-compose%.[^/]+%.ya?ml"] = "yaml.docker-compose",
		[".*/compose%.ya?ml"] = "yaml.docker-compose",
		[".*/compose%.[^/]+%.ya?ml"] = "yaml.docker-compose",
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
