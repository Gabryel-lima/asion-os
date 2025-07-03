#!/usr/bin/env bash
set -e

sudo apt update
sudo apt install build-essential bison flex libgmp-dev libmpfr-dev libmpc-dev texinfo

PROJECT_ROOT="/home/gabry/Documentos/projects/asion-os"
SRC_DIR="$PROJECT_ROOT/src"
mkdir -p "$SRC_DIR"
cd "$SRC_DIR"

baixar_e_extrair() {
    local TAR="$1"
    local URL="$2"
    local DIR="$3"

    if [[ ! -f "$TAR" ]]; then
        echo "↓ Baixando $TAR..."
        wget -q --show-progress "$URL"
    fi

    if [[ ! -d "$DIR" ]]; then
        echo "↪ Extraindo $TAR..."
        if ! tar -xf "$TAR"; then
            echo "✗ Extração falhou, removendo $TAR e tentando novamente..."
            rm -f "$TAR"
            wget -q --show-progress "$URL"
            tar -xf "$TAR"
        fi
    else
        echo "✓ Diretório $DIR já existe; pulando extração."
    fi
}

########################
# 1) Binutils 2.42
########################
BINUTILS_VER="2.42"
BINUTILS_TAR="binutils-${BINUTILS_VER}.tar.xz"
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/${BINUTILS_TAR}"
BINUTILS_DIR="binutils-${BINUTILS_VER}"

baixar_e_extrair "$BINUTILS_TAR" "$BINUTILS_URL" "$BINUTILS_DIR"

########################
# 2) GCC 14.1.0
########################
GCC_VER="14.1.0"
GCC_TAR="gcc-${GCC_VER}.tar.xz"
GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/${GCC_TAR}"
GCC_DIR="gcc-${GCC_VER}"

baixar_e_extrair "$GCC_TAR" "$GCC_URL" "$GCC_DIR"

PROJECT_ROOT="/home/gabry/Documentos/projects/asion-os"
PREFIX="$PROJECT_ROOT/opt/cross"
TARGET=i686-elf
PATH="$PREFIX/bin:$PATH"

BINUTILS_SRC="$PROJECT_ROOT/src/binutils-2.42"
GCC_SRC="$PROJECT_ROOT/src/gcc-14.1.0"

# -------- Binutils --------
mkdir -p "$PROJECT_ROOT/src/build-binutils"
cd       "$PROJECT_ROOT/src/build-binutils"

"$BINUTILS_SRC/configure" --target="$TARGET" --prefix="$PREFIX" \
    --with-sysroot --disable-nls --disable-werror
make -j"$(nproc)"
make install

# -------- GCC (só C) ------
mkdir -p "$PROJECT_ROOT/src/build-gcc"
cd       "$PROJECT_ROOT/src/build-gcc"

"$GCC_SRC/configure" --target="$TARGET" --prefix="$PREFIX" \
    --disable-nls --enable-languages=c \
    --without-headers --disable-hosted-libstdcxx
make -j"$(nproc)" all-gcc
make -j"$(nproc)" all-target-libgcc
make install-gcc
make install-target-libgcc
