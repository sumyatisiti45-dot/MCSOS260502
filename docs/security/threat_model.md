# Threat Model

## Initial Risks
- Repository located in /mnt/c
- Wrong target architecture
- Missing QEMU
- Missing OVMF
- Host compiler contamination
- Broken build reproducibility

## Mitigation
- Use WSL2 Linux filesystem
- Verify ELF using readelf
- Validate toolchain before build
- Use fixed Makefile configuration

