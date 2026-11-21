# golden.img.xz — the pre-captured memory image

This module ships one atomically-captured RAM image of the compromised server and
rewrites a handful of fixed-length hex tokens in it per build, so every student's
answers are unique without re-capturing memory each build.

`golden.img.xz` is **not committed as a placeholder** — a real build needs the real
capture. Regenerate it (and `golden_tokens.json`) like this:

## Why atomic capture

A live, in-guest capture (LiME) of a running VM is non-atomic: the kernel mutates
page tables during the seconds-long read, so page-table levels disagree and
Volatility's list-walks and even psscan/strings drop single-copy artefacts
non-deterministically ("memory smear"). The hypervisor can freeze the guest's vCPUs
and read a consistent snapshot; that is how VM memory is captured in practice.

## Capture procedure (one-off, needs Proxmox host access)

1. Build the lab so the compromised server is running with this build's artefacts.
2. On the Proxmox host, for the compromised_server VMID, via the QEMU monitor:

   ```
   stop
   pmemsave 0 0x60000000 /var/tmp/golden_cs.raw     # 0x60000000 = 1536 MiB guest RAM
   cont
   ```

   (`stop`/`cont` freeze and resume the guest; the dump is taken while paused, so it
   is internally consistent. Adjust the size to the guest's RAM if memory_cap changes.)
3. Copy `/var/tmp/golden_cs.raw` off the host.
4. Record that build's baked token values into `golden_tokens.json` (the live values
   the artefacts planted — read them from the compromised server, or from the build's
   datastore values).
5. Compress and place:

   ```
   xz -9 -T0 -c golden_cs.raw > golden.img.xz
   ```

6. Verify on an analyst machine: decompress, run `patch_golden.py` with sample values,
   and confirm Volatility psscan/strings recover the patched tokens.
