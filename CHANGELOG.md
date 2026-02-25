# Changelog

All notable changes to this skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-02-24

### Changed
- **BREAKING**: Script now operates in read-only mode
- Agent now handles `terraform init` before calling script
- Removed `terraform init` execution from check.sh
- Removed terraform CLI dependency check from script
- Removed provider configuration validation from script

### Security
- Eliminated external downloads from script (moved to agent context)
- Script now only reads existing schema data
- Provider downloads visible to user during agent-managed init
- Added provider name length limit (max 64 chars)
- Improved security posture for Agent Trust Hub audit

### Documentation
- Updated SKILL.md workflow to show agent-managed initialization
- Clarified agent vs script responsibilities
- Enhanced security documentation

## [0.2.0] - 2026-02-24

### Security
- Added input validation for provider names (alphanumeric, hyphens, underscores only)
- Replaced shell interpolation with jq `--arg` for safe string handling
- Eliminated grep-based provider key extraction to prevent injection attacks
- Added security documentation and best practices to SKILL.md

## [0.1.0] - 2026-02-23

### Added
- Initial implementation
- Support for all 6 Terraform provider capability types:
  - `resources` - Standard managed resources
  - `data-sources` - Read-only data queries
  - `actions` - Imperative operations
  - `list` - List resources
  - `ephemeral` - Ephemeral resources
  - `functions` - Provider functions
- Agent-driven workflow where agent creates provider configuration
- Dependency checks for terraform and jq with helpful error messages
- Detailed workflow documentation in SKILL.md
- Example provider configurations for common providers
