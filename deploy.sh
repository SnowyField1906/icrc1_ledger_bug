ABSOLUTE_SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)

dfx deploy main
npx tsx "$ABSOLUTE_SCRIPT_DIR/index.ts" || :
dfx canister call main acornPrincipal