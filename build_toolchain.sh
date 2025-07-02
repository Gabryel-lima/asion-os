#!/usr/bin/env bash
set -e

sudo apt update
sudo apt install build-essential bison flex libgmp-dev libmpfr-dev libmpc-dev texinfo

PROJECT_ROOT="/home/gabry/Documentos/projects/asion-os"
SRC_DIR="$PROJECT_ROOT/src"
mkdir -p "$SRC_DIR"
cd "$SRC_DIR"

########################
# 1) Binutils 2.42
########################
BINUTILS_VER="2.42"
BINUTILS_TAR="binutils-${BINUTILS_VER}.tar.xz"
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/${BINUTILS_TAR}"
BINUTILS_DIR="binutils-${BINUTILS_VER}"

# Baixar se o tarball NÃO existir
if [[ ! -f "$BINUTILS_TAR" ]]; then
    echo "↓ Baixando $BINUTILS_TAR..."
    wget -q --show-progress "$BINUTILS_URL"
else
    echo "✓ Tarball $BINUTILS_TAR já existe; pulando download."
fi

# Extrair se o diretório NÃO existir
if [[ ! -d "$BINUTILS_DIR" ]]; then
    echo "↪ Extraindo $BINUTILS_TAR..."
    tar -xf "$BINUTILS_TAR"
else
    echo "✓ Diretório $BINUTILS_DIR já existe; pulando extração."
fi

########################
# 2) GCC 14.1.0
########################
GCC_VER="14.1.0"
GCC_TAR="gcc-${GCC_VER}.tar.xz"
GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/${GCC_TAR}"
GCC_DIR="gcc-${GCC_VER}"

if [[ ! -f "$GCC_TAR" ]]; then
    echo "↓ Baixando $GCC_TAR..."
    wget -q --show-progress "$GCC_URL"
else
    echo "✓ Tarball $GCC_TAR já existe; pulando download."
fi

if [[ ! -d "$GCC_DIR" ]]; then
    echo "↪ Extraindo $GCC_TAR..."
    tar -xf "$GCC_TAR"
else
    echo "✓ Diretório $GCC_DIR já existe; pulando extração."
fi

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
