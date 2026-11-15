#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

mkdir -p ${OUTPUT_DIR}/bin

# check BINARY presence in PATH
for BINARY in ${BINARIES}; do
    [ -z $(which $BINARY) ] &&
        echo $BINARY not found in \$PATH &&
        false || true
done

# sym link BINARY
for BINARY in ${BINARIES}; do
    [ ! -h ${OUTPUT_DIR}/bin/$BINARY ] &&
        ln -s $(which $BINARY) ${OUTPUT_DIR}/bin/$BINARY ||
        true
done

# CMake 4 refuses projects declaring cmake_minimum_required < 3.5 (uchardet,
# mbedtls, ...). The build runs under `env -i`, so wrap cmake to set the policy.
if [ -h ${OUTPUT_DIR}/bin/cmake ]; then
    CMAKE_BIN=$(readlink ${OUTPUT_DIR}/bin/cmake)
    rm ${OUTPUT_DIR}/bin/cmake
    printf '#!/bin/sh\nexport CMAKE_POLICY_VERSION_MINIMUM=3.5\nexec "%s" "$@"\n' "${CMAKE_BIN}" >${OUTPUT_DIR}/bin/cmake
    chmod +x ${OUTPUT_DIR}/bin/cmake
fi
