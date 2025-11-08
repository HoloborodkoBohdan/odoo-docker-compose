#!/bin/bash
# Odoo Module Test Runner
# Usage: ./run-tests.sh <module_name> [database_name] [options]

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please create .env from .env.example"
    exit 1
fi

# Default values
MODULE_NAME="$1"
DB_NAME="${2:-test_db}"
CONTAINER_NAME="odoo_${ODOO_VERSION}"

# Help message
if [ -z "$MODULE_NAME" ] || [ "$MODULE_NAME" == "-h" ] || [ "$MODULE_NAME" == "--help" ]; then
    echo "Odoo Module Test Runner"
    echo ""
    echo "Usage: ./run-tests.sh <module_name> [database_name] [options]"
    echo ""
    echo "Arguments:"
    echo "  module_name       Name of the module to test (required)"
    echo "  database_name     Database to use for testing (default: test_db)"
    echo ""
    echo "Options:"
    echo "  --install         Install module before testing (default behavior)"
    echo "  --update          Update existing module before testing"
    echo "  --tags TAGS       Run specific test tags (e.g., 'post_install,at_install')"
    echo "  --log-level LEVEL Set log level (debug, info, warn, error)"
    echo ""
    echo "Examples:"
    echo "  ./run-tests.sh my_module"
    echo "  ./run-tests.sh my_module custom_test_db"
    echo "  ./run-tests.sh my_module test_db --update"
    echo "  ./run-tests.sh my_module test_db --tags post_install"
    echo ""
    exit 0
fi

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}Error: Odoo container '${CONTAINER_NAME}' is not running!${NC}"
    echo "Start it with: docker-compose up -d"
    exit 1
fi

# Parse options
MODE="install"  # Default: install mode
TEST_TAGS=""
LOG_LEVEL="test"

shift  # Skip module name
shift 2>/dev/null || true  # Skip database name if provided

while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            MODE="update"
            shift
            ;;
        --install)
            MODE="install"
            shift
            ;;
        --tags)
            TEST_TAGS="$2"
            shift 2
            ;;
        --log-level)
            LOG_LEVEL="$2"
            shift 2
            ;;
        *)
            echo -e "${YELLOW}Warning: Unknown option $1${NC}"
            shift
            ;;
    esac
done

# Determine the module operation flag
if [ "$MODE" == "update" ]; then
    MODULE_FLAG="-u"
    ACTION="Updating and testing"
else
    MODULE_FLAG="-i"
    ACTION="Installing and testing"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Odoo Module Testing${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Module:    ${YELLOW}${MODULE_NAME}${NC}"
echo -e "Database:  ${YELLOW}${DB_NAME}${NC}"
echo -e "Mode:      ${YELLOW}${MODE}${NC}"
echo -e "Container: ${YELLOW}${CONTAINER_NAME}${NC}"
[ -n "$TEST_TAGS" ] && echo -e "Tags:      ${YELLOW}${TEST_TAGS}${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Build the test command
TEST_CMD="odoo -c /etc/odoo/odoo.conf --test-enable --stop-after-init -d ${DB_NAME} ${MODULE_FLAG} ${MODULE_NAME} --log-level=${LOG_LEVEL}"

# Add test tags if specified
if [ -n "$TEST_TAGS" ]; then
    TEST_CMD="${TEST_CMD} --test-tags ${TEST_TAGS}"
fi

echo -e "${ACTION} module '${MODULE_NAME}'..."
echo -e "${YELLOW}Command: ${TEST_CMD}${NC}"
echo ""

# Run tests
if docker exec -it "${CONTAINER_NAME}" ${TEST_CMD}; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Tests completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}✗ Tests failed!${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi
