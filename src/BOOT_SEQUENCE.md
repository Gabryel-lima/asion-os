# asion-os: Bare Bones Build Notes

*Last updated: 2025‑07‑01*

## Overview

This document captures the exact steps used to assemble, compile, link, verify and package the very first “bare bones” kernel for **asion‑os**. It is meant to live at the project root (`README.md` or `docs/BOOT_SEQUENCE.md`) so you can reproduce the build with a single glance.

---

## 1. Assemble the bootstrap stub

```bash
i686-elf-as boot.s -o boot.o
```

*Generates `boot.o` — contains the Multiboot header and `_start` entry.*

## 2. Compile the C kernel

```bash
i686-elf-gcc -c kernel.c -o kernel.o \
  -std=gnu99 -ffreestanding -O2 -Wall -Wextra
```

*Produces `kernel.o` — freestanding code that writes to VGA text buffer.*

## 3. Link objects into a flat ELF kernel

```bash
i686-elf-gcc -T linker.ld -o myos.bin \
  -ffreestanding -O2 -nostdlib \
  boot.o kernel.o -lgcc
```

*Why the compiler as linker?*
It automatically adds the required `libgcc` runtime stubs and ensures
all options are consistent.

*Result:* **`myos.bin`** — the final kernel image the bootloader expects.

## 4. Sanity‑check the Multiboot header

```bash
grub-file --is-x86-multiboot myos.bin && echo "multiboot confirmed"
```

Exit status `0` confirms the header is within the first 8 KiB.

## 5. Package into a bootable ISO (GRUB)

```bash
mkdir -p iso/boot/grub
cp myos.bin iso/boot/kernel.elf          # keep extension for clarity
cat > iso/boot/grub/grub.cfg <<'EOF'
set timeout=0
set default=0
menuentry "asion-os" {
    multiboot2 /boot/kernel.elf
    boot
}
EOF

grub-mkrescue -o asion-os.iso iso
```

## + Se você usa o terminal integrado do VS Code (Snap)

O VS Code instalador via Snap exporta variáveis de ambiente que levam o loader às libs do core20. Desative-as só para a sessão:

```bash
unset GTK_PATH GIO_MODULE_DIR LD_LIBRARY_PATH
```

## 6. Launch in QEMU

```bash
qemu-system-i386 -cdrom asion-os.iso
```

A “Hello, kernel World!” message in white on black signals success.

---

### File‑flow diagram

```
boot.s  ┐
        ├─▶ boot.o   ┐
kernel.c┘            ├─▶ myos.bin ──▶ asion-os.iso ──▶ QEMU
        kernel.o ────┘
```

---

## Next milestones

* Implement newline handling & scrolling in `terminal_putchar`.
* Set up GDT and enable paging.
* Introduce a simple memory allocator.
