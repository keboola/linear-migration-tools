#!/bin/bash

set -e

PROJECT_KEY="$1"
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            PROJECT_KEY="$1"
            shift
            ;;
    esac
done

if [ -z "$PROJECT_KEY" ]; then
    echo "Usage: $0 <project-key> [--dry-run]"
    echo "Example: $0 PAT"
    echo "Example: $0 PAT --dry-run"
    exit 1
fi

if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Converting all Epics to Tasks in project: $PROJECT_KEY"
else
    echo "Converting all Epics to Tasks in project: $PROJECT_KEY"
fi

check_acli_installed() {
    if ! command -v acli &> /dev/null; then
        echo "Error: acli is not installed or not in PATH"
        echo "Please install acli: https://developer.atlassian.com/cloud/acli/installation/"
        exit 1
    fi
}

get_epics_in_project() {
    local project_key="$1"
    local epics=$(acli jira workitem search --jql "project = $project_key AND issuetype = Epic" --paginate --json | jq -r '.[].key')
    echo "$epics"
}


convert_epic_to_task() {
    local issue_key="$1"

    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would convert Epic $issue_key to Task"
    else
        echo "Converting Epic $issue_key to Task..."
        acli jira workitem edit --key "$issue_key" --type "Task" --yes
    fi
}

main() {
    check_acli_installed

    echo "Getting all Epics in project $PROJECT_KEY..."
    epics=$(get_epics_in_project "$PROJECT_KEY")

    if [ -z "$epics" ]; then
        echo "No Epics found in project $PROJECT_KEY"
    else
        echo "Found Epics in project $PROJECT_KEY:"
        echo "$epics"
        echo ""

        while IFS= read -r epic_key; do
            if [ -n "$epic_key" ]; then
                convert_epic_to_task "$epic_key"
                echo ""
            fi
        done <<< "$epics"
    fi

    echo "Epic conversion completed successfully!"
}

main
