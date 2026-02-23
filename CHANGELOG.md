# Changelog

All notable changes to this skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-23

### Added
- Initial release
- Support for all 6 Terraform provider capability types:
  - `resources` - Standard managed resources
  - `data-sources` - Read-only data queries
  - `actions` - Imperative operations
  - `list` - List resources
  - `ephemeral` - Ephemeral resources
  - `functions` - Provider functions
- Auto-generation of provider configuration if none exists
- Dependency checks for terraform and jq with helpful error messages
- Claude Code marketplace metadata
