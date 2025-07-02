# Projeto de Sistema Operacional — Roteiro de Estudos e Desenvolvimento

> “A jornada de mil léguas começa com um único passo.” — *Lao‑Tzu*

Este **README** descreve um percurso incremental para construir (e aprender) um micro‑kernel escrito majoritariamente em **C**, com poucos trechos em assembly, visando a arquitetura **x86‑64**.  Todos os passos foram pensados para quem utiliza Linux (Ubuntu 20.04 +), mas podem ser adaptados para outras distribuições.

---

## 1. Objetivos do Projeto

1. **Entender** a transição *bootloader → kernel* e os requisitos de um ambiente *bare‑metal*.
2. **Implementar** gradualmente os subsistemas essenciais (interrupções, memória, drivers, multitarefa, sistema de arquivos).
3. **Documentar** cada etapa no repositório para futura referência e colaboração.

> **Resultado esperado**: ao final deste roteiro, você terá um kernel 64‑bit capaz de inicializar em hardware virtual (QEMU) e executar um programa em espaço de usuário simples via chamadas de sistema.

---

## 2. Pré‑requisitos

| Ferramenta          | Versão sugerida | Referência                                                                              |
| ------------------- | --------------- | --------------------------------------------------------------------------------------- |
| **x86\_64‑elf‑gcc** | >= 13           | [https://wiki.osdev.org/GCC\_Cross-Compiler](https://wiki.osdev.org/GCC_Cross-Compiler) |
| **binutils**        | >= 2.40         | idem                                                                                    |
| **NASM**            | >= 2.16         | [https://www.nasm.us/](https://www.nasm.us/)                                            |
| **GRUB 2**          | >= 2.06         | [https://www.gnu.org/software/grub/](https://www.gnu.org/software/grub/)                |
| **QEMU**            | >= 8.2          | [https://www.qemu.org/](https://www.qemu.org/)                                          |
| **Python 3 + Make** | –               | ferramentas de automação                                                                |

> Use o script `scripts/toolchain.sh` (fornecido neste repositório) para compilar o *cross‑compiler* de forma reproduzível.

---

## 3. Estrutura de Diretórios

```text
.
├── boot/          # código do bootloader GRUB + assets de imagem ISO
├── kernel/        # fonte C/ASM do kernel
├── lib/           # rotinas de apoio (libc mínima, string, memória)
├── scripts/       # utilidades de build, criação de ISO, cross‑toolchain
├── docs/          # artigos, diagramas e anotações adicionais
├── build/         # artefatos gerados (kernel.elf, os.iso, symbols)
└── Makefile       # alvo principal: make run (compila tudo e inicia QEMU)
```

---

## 4. Roteiro de Desenvolvimento

| Fase                   | Meta técnica                                                                | Recursos sugeridos                                                      |
| ---------------------- | --------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| **0. Ambiente**        | Instalar toolchain cruzada, NASM, QEMU e GRUB.                              | OSDev Wiki — *GCC Cross‑Compiler*                                       |
| **1. Bare Bones**      | Imprimir "Hello, kernel world!" na VGA; ISO bootável.                       | [https://wiki.osdev.org/Bare\_Bones](https://wiki.osdev.org/Bare_Bones) |
| **2. GDT & IDT**       | Configurar Tabela Global de Descritores e vetores de interrupção.           | *JamesM’s Kernel Dev – Cap. 3–5*                                        |
| **3. Paging**          | Ativar paginação de identidade + *Higher‑Half Kernel* (0xFFFFFFFF80000000). | OSDev: *Paging*                                                         |
| **4. Drivers básicos** | Teclado (PIC 8259 A), PIT timer (canal 0).                                  | `cfenollosa/os-tutorial` passos 17–24                                   |
| **5. Long Mode**       | Migrar para 64 bits; reescrever *boot stub* em assembly.                    | OSDev: *Creating a 64‑bit Kernel*                                       |
| **6. Alocador**        | Implementar *buddy allocator* ou *bitmap allocator* + `kmalloc`.            | Livro *Operating Systems: From 0 to 1*                                  |
| **7. Multitarefa**     | Scheduler round‑robin preemptivo (IRQ 0); context switch.                   | *JamesM’s Kernel Dev – Cap. 8*                                          |
| **8. Syscalls**        | Interface simples para userland (ex.: `write`, `read`).                     | wiki.osdev.org/System\_Call                                             |
| **9. Filesystem**      | Driver FAT‑12/FAT‑32 ou EXT2, montado em `ramdisk`.                         | `littlefs` ou implementação própria                                     |
| **10. Userland**       | Carregador ELF + *libc* mínima; rodar `/bin/sh` simples.                    | [Liber8/libc](https://github.com/littlec/libc)                          |

---

## 5. Compilação e Execução Rápidas

```bash
# 1️⃣ Compilar tudo e gerar os.iso
$ make

# 2️⃣ Rodar em QEMU (headless + GDB)
$ make run
# (em outra shell)
$ gdb -x scripts/gdbinit build/kernel.elf
```

Para depuração gráfica substitua `run` por `run-gui` (configurado no Makefile).

---

## 6. Convenções de Código

* **C99 estrito** (`-std=c99 -Wall -Wextra -Werror`).
* funções e símbolos do kernel prefixados por `k_`.
* cabeçalhos internos em `include/` usam *include guards*.
* Sem dependências externas além da toolchain.

---

## 7. Contribuindo

1. *Fork* o repositório e crie uma *feature branch* (`git checkout -b feat/nova‑feature`).
2. Siga o *clang‑format* definido em `.clang-format`.
3. Envie *pull request* com descrição detalhada e **link** para a especificação/hardware utilizada.

---

## 8. Licença

Distribuído sob a licença **MIT** — consulte `LICENSE` para mais detalhes.

---

## 9. Referências Essenciais

* OSDev Wiki — [https://wiki.osdev.org/](https://wiki.osdev.org/)
* *cfenollosa/os-tutorial* — [https://github.com/cfenollosa/os-tutorial](https://github.com/cfenollosa/os-tutorial)
* *JamesM’s Kernel Development* (espelhado) — [https://wiki.osdev.org/James\_Mollison's\_Tutorials](https://wiki.osdev.org/James_Mollison's_Tutorials)
* *The Little Book About OS Development* — [https://littleosbook.github.io/](https://littleosbook.github.io/)
* *Operating Systems: From 0 to 1* — [https://github.com/tuhdo/os01](https://github.com/tuhdo/os01)
* Intel® 64 and IA‑32 Architectures — *Developer Manuals* — [https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
