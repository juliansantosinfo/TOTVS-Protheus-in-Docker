#!/bin/bash
# ==============================================================================
# SCRIPT: scripts/push.sh
# DESCRIPTION: Master script to push all Docker images to Docker Hub.
#              Calls the individual push.sh script in each service directory.
# ==============================================================================

set -euo pipefail

readonly VALID_APPS=("appserver" "dbaccess" "licenseserver" "mssql" "postgres" "smartview")
APPS_TO_PUSH=("${VALID_APPS[@]}")

echo "=========================================================="
echo "🚀 STARTING MASTER PUSH"
echo "=========================================================="

MASTER_SUCCESS=true

for APP_NAME in "${APPS_TO_PUSH[@]}"; do
    echo ""
    echo ">>> 📤 PUSHING SERVICE: $APP_NAME <<<"
    
    SCRIPT_PATH="./${APP_NAME}/push.sh"

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "🚨 ERROR: Push script not found: $SCRIPT_PATH" >&2
        MASTER_SUCCESS=false
        continue
    fi

    # Execute the push script
    if ! bash "$SCRIPT_PATH"; then
        echo "❌ FAILURE: Push for '$APP_NAME' failed." >&2
        MASTER_SUCCESS=false
    else
        echo "✅ SUCCESS: Push for '$APP_NAME' completed."
    fi
done

if [ "$MASTER_SUCCESS" = true ]; then
    echo ""
    echo "🎉 ALL PUSHES COMPLETED SUCCESSFULLY!"
    exit 0
else
    echo ""
    echo "🛑 SOME PUSHES FAILED." >&2
    exit 1
fi
