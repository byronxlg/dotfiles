# Coding Agent Instructions

## General Guidelines

### Code Quality

- Write clean, readable, and maintainable code
- Follow existing code style and conventions in the repository
- Add comments for complex logic or non-obvious behavior
- Prefer explicit over implicit code
- Use meaningful variable and function names

### Error Handling

- Always handle errors appropriately
- Provide meaningful error messages
- Fail gracefully when possible
- Validate inputs before processing

### Documentation

- Update relevant documentation when making changes
- Keep README files up to date
- Add inline comments for complex algorithms

### Performance

- Consider performance implications of changes
- Optimize critical paths when necessary
- Avoid premature optimization
- Profile before optimizing

### Dependencies

- Minimize external dependencies
- Keep dependencies up to date
- Document why specific dependencies are needed
- Use version pinning for production dependencies

## Language-Specific Guidelines

### Python

- Always check Python code for Ruff linting issues before committing
- Run `ruff check` and `ruff format` to ensure code quality and consistency
- Fix all Ruff warnings and errors before submitting changes
- Follow PEP 8 style guidelines (enforced by Ruff)

### Configuration Files

- Use consistent formatting
- Comment non-obvious settings
- Group related settings together
- Document default vs custom values

## Communication

### When Making Changes

- Explain what you're changing and why
- Highlight any breaking changes
- Suggest testing steps when appropriate
- Ask for clarification if requirements are unclear
- Do not implement backwards compatibility
- Do not implement fail safes

### When Uncertain

- Ask questions rather than making assumptions
- Propose solutions and wait for confirmation
- Suggest alternatives when appropriate
- Document trade-offs in decisions

## MCP Tools

### Using MCP Tools to Answer Queries

- **Always check available MCP tools first** before attempting to answer queries that might require external data or services
- Use `list_mcp_resources` to discover available resources from configured MCP servers
- Use `fetch_mcp_resource` to retrieve specific resources when needed
- When answering questions that could benefit from external data (GitHub repositories, databases, APIs, etc.), prioritize using MCP tools over making assumptions or creating placeholder content
- MCP tools provide access to real-time data and should be leveraged to provide accurate, up-to-date information

### File Creation Guidelines

- **Do not default to creating files** to answer questions or provide information
- Prefer using existing tools, MCP resources, or providing answers directly in conversation
- Only create files when explicitly requested by the user or when it's necessary for implementing a specific feature
- When information can be provided conversationally or through existing resources, choose that approach over file creation
- If unsure whether a file should be created, ask the user first rather than assuming
