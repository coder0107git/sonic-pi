#!/bin/bash
set -e # Quit script on error
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKING_DIR="$(pwd)"

cleanup_function() {
    # Restore working directory as it was prior to this script running on exit
    cd "${WORKING_DIR}"
}
trap cleanup_function EXIT

args=("$@")
offline_build=false

# extract options and their arguments into variables.
while [ -n "$1" ]; do
    case "$1" in
        -c|--config)
            shift 2
            ;;
        -n|--no-imgui)
            shift
            ;;
        -s|--system-libs)
            shift
            ;;
        -o|--offline-build)
            offline_build=true
            shift
            ;;
        --) shift ; break ;;
        *) echo "Invalid argument: $1" ; exit 1 ;;
    esac
done

echo "Compiling Erlang/Elixir files..."
cd "${SCRIPT_DIR}"/server/beam/tau

if [ "$offline_build" == true ]; then
    MIX_ENV=prod mix deps.clean --unused
    MIX_ENV=prod mix deps.compile
    MIX_ENV=prod mix release --overwrite --no-deps-check
else
    MIX_ENV=prod mix tau.release
fi



