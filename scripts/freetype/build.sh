#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}
meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${OUTPUT_DIR}" \
    -Dbrotli=disabled \
    -Dbzip2=disabled \
    -Dharfbuzz=enabled \
    -Dmmap=disabled \
    -Dpng=enabled \
    -Dtests=disabled \
    -Dzlib=enabled
# libpng < 1.6.44 wrongly includes <fp.h> on newer Apple SDKs (fixed upstream by dropping TARGET_OS_MAC)
for f in subprojects/libpng-*/pngpriv.h; do [ -f "$f" ] && sed -i "" "s/ || defined(TARGET_OS_MAC)//" "$f"; done
meson compile -C build
meson install -C build
