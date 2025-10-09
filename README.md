# linear-migration-tools

Helper scripts for migrating issues between Jira and Linear. These tools use the Atlassian CLI (`acli`) to manipulate Jira issues during migration processes.

## Prerequisites

- [Atlassian CLI (acli)](https://developer.atlassian.com/cloud/acli/installation/) must be installed and configured
- `jq` for JSON parsing

## Tools

### to-linear/

Scripts for preparing Jira issues before migrating TO Linear:

#### `add-parent-labels.sh`
**Purpose**: Adds parent relationship labels to child issues of Epics
**Motivation**: Linear doesn't have the same Epic/Story hierarchy as Jira. This script adds `parentIs<EPIC-KEY>` labels to all child issues, preserving the parent-child relationships for reference after migration.

Usage:
```bash
./to-linear/add-parent-labels.sh <PROJECT-KEY> [--dry-run]
```

#### `convert-epic-to-task.sh`
**Purpose**: Converts all Epic issues to Task issue type
**Motivation**: Linear doesn't have Epic issue types. Converting Epics to Tasks before migration ensures they migrate as regular issues instead of being dropped or causing errors.

Usage:
```bash
./to-linear/convert-epic-to-task.sh <PROJECT-KEY> [--dry-run]
```

#### `label-bugs.sh`
**Purpose**: Adds "Bug" labels to all Bug issue types that don't already have bug labels
**Motivation**: Preserves issue type information through labels when migrating to Linear, where the original issue type metadata might not be preserved.

Usage:
```bash
./to-linear/label-bugs.sh <PROJECT-KEY> [--dry-run]
```

### from-linear/

Scripts for processing issues migrated FROM Linear back to Jira:

#### `create-epics.sh`
**Purpose**: Converts issues labeled with "IssueTypeEpic" back to Epic issue type
**Motivation**: Recreates Epic hierarchy after migrating issues back from Linear. Issues that were originally Epics and were marked with "IssueTypeEpic" labels get converted back to proper Epic issue types.

Usage:
```bash
./from-linear/create-epics.sh <PROJECT-KEY> [--dry-run]
```

## Common Options

- `<PROJECT-KEY>`: Jira project key (e.g., "PAT", "PROJ")
- `--dry-run`: Preview changes without executing them