-- Validate YAML with Kubernetes, Compose, Helm and CI schemas.

local kubernetes_schema_version = vim.g.kubernetes_schema_version or "master"
local kubernetes_schema_directory = kubernetes_schema_version == "master" and "master-standalone-strict"
	or kubernetes_schema_version .. "-standalone-strict"
local kubernetes_schema_url = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/"
	.. kubernetes_schema_directory
	.. "/all.json"

---@type vim.lsp.Config
return {
	filetypes = { "yaml", "yaml.gitlab", "yaml.ghaction", "yaml.github-action" },
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = {
			format = { enable = true },
			validate = true,
			keyOrdering = false,
			schemaStore = {
				enable = true,
				url = "https://www.schemastore.org/api/json/catalog.json",
			},
			schemas = {
				[kubernetes_schema_url] = {
					"k8s/**/*.yaml",
					"k8s/**/*.yml",
					"kubernetes/**/*.yaml",
					"kubernetes/**/*.yml",
					"manifests/**/*.yaml",
					"manifests/**/*.yml",
				},
				["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
					"*docker-compose*.yaml",
					"*docker-compose*.yml",
					"compose*.yaml",
					"compose*.yml",
				},
				["https://json.schemastore.org/chart.json"] = { "Chart.yaml" },
				["https://json.schemastore.org/kustomization.json"] = {
					"kustomization.yaml",
					"kustomization.yml",
				},
				["https://json.schemastore.org/github-workflow.json"] = {
					".github/workflows/*.yaml",
					".github/workflows/*.yml",
				},
				["https://json.schemastore.org/github-action.json"] = {
					"action.yaml",
					"**/action.yaml",
					"action.yml",
					"**/action.yml",
				},
				["https://json.schemastore.org/gitlab-ci.json"] = {
					".gitlab-ci.yaml",
					".gitlab-ci.yml",
				},
			},
		},
	},
}
