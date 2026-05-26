Preferred CLI tools for shell commands:

- **File Search**: Use `fd --hidden` over `find` - faster, respects .gitignore, better defaults; always pass `--hidden` in repos where content lives in hidden directories (e.g. dotfiles)
- **Text Search**: Use `rg --hidden` over `grep` - faster, respects .gitignore, better output formatting; always pass `--hidden` in repos where content lives in hidden directories (e.g. dotfiles)
- **Interactive Selection**: Use `fzf` for fuzzy finding and selecting from lists/results
- **Data Processing**: Use `jq` for JSON parsing/manipulation, `yq` for YAML/XML
- **Text Processing**: Use `sed` for stream editing, `awk` for pattern scanning and processing
