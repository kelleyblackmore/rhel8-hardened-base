#!/bin/bash
# RHEL 8 STIG Master Hardening Script
# Executes all STIG category scripts in proper order

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting RHEL 8 STIG Hardening Process..."
echo "Script directory: $SCRIPT_DIR"

# Execute STIG scripts in dependency order
STIG_SCRIPTS=(
    "stig-system-maintenance.sh"    # System updates and packages first
    "stig-account-management.sh"    # User and account security
    "stig-filesystem.sh"            # File system permissions and access
    "stig-network.sh"               # Network security configuration  
    "stig-audit-logging.sh"         # Audit and logging (last, to catch all changes)
)

for script in "${STIG_SCRIPTS[@]}"; do
    script_path="$SCRIPT_DIR/$script"
    
    if [ -f "$script_path" ] && [ -x "$script_path" ]; then
        echo ""
        echo "=========================================="
        echo "Executing: $script"
        echo "=========================================="
        "$script_path"
        echo "Completed: $script"
    else
        echo "Warning: Script not found or not executable: $script_path"
    fi
done

echo ""
echo "=========================================="
echo "RHEL 8 STIG Hardening Complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "- System maintenance and updates applied"
echo "- Account management controls configured"  
echo "- File system permissions secured"
echo "- Network security settings applied"
echo "- Audit and logging configured"
echo ""
echo "Note: Some settings may be limited in container environments."
echo "Host-level controls should be configured separately."