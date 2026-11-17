# Installs QEMU user-mode emulators, registered with binfmt_misc so foreign-architecture ELF
# binaries run directly, plus gdb-multiarch.
class cross_arch_emulation::install {
  ensure_packages(['qemu-user-static', 'binfmt-support', 'gdb-multiarch'])
}
