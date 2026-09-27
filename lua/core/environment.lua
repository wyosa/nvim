-- Fallback PATH for the Rust compiler installed through Homebrew rustup.

-- Extend PATH only when cargo cannot already be found.
if vim.fn.executable("cargo") == 0 then
	local candidates = { vim.fn.expand("~/.cargo/bin") }
	local rustup = vim.fn.exepath("rustup")
	if rustup ~= "" then
		local resolved = vim.uv.fs_realpath(rustup)
		if resolved then
			table.insert(candidates, vim.fs.dirname(resolved))
		end
	end
	for _, directory in ipairs(candidates) do
		if vim.fn.executable(directory .. "/cargo") == 1 then
			vim.env.PATH = directory .. (vim.fn.has("win32") == 1 and ";" or ":") .. (vim.env.PATH or "")
			break
		end
	end
end
