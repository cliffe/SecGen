# Bundled Volatility 3 Linux symbol tables (ISFs)

Each supported base kernel has two files here:

- `<kernelrelease>.json.xz` - the Volatility 3 ISF (symbol table) for that kernel.
- `<kernelrelease>.banner` - the exact `/proc/version` the ISF was built for.

At provision time `select_isf.sh` compares the running kernel's `/proc/version`
to each `.banner` and installs the matching ISF into Volatility's symbol path.
If nothing matches, the build fails on purpose.

Generate a new pair with `../generate_isf.sh` on a box running the target
kernel, then commit both files here. An ISF goes stale when a base template's
kernel changes; the hard build failure is the signal to regenerate.
