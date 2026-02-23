# Terraform Schema Inspector Skill

Agent skill for identifying Terraform provider support for resources, data sources, actions, list resources, ephemeral resources, and functions.

## Installation

Copy this directory to your agent's skills folder or install via your agent's skill management system.

## Usage

The agent will automatically use this skill when you ask about Terraform provider capabilities:

- "What resources does the AWS provider support?"
- "Show me data sources for azurerm"
- "Does the google provider have any actions?"
- "List all functions in the AWS provider"

## Requirements

- Terraform CLI
- jq (JSON processor)

The script auto-generates a minimal provider configuration if needed.

## Structure

```
terraform-schema-inspector-skill/
├── SKILL.md           # Skill definition
├── scripts/
│   └── check.sh       # Capability checker
├── CHANGELOG.md       # Version history
├── LICENSE            # MIT License
└── README.md          # This file
```
