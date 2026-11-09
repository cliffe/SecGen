---
name: create-metactf-challenge
description: Create or modify a randomised reverse engineering challenge in SecGen's MetaCTF module (modules/utilities/unix/ctf/metactf) - the program.c.template + build.zsh pair, per-build randomisation with sed placeholders, registering the path in the metactf_challenge generator, wiring it into a scenario, and verifying it on a real build. Use when asked to "add a metactf challenge", "create a new reversing challenge", "write a new CTF binary for the SRE labs", "randomise this challenge", or to debug a metactf challenge that fails to build, is missing from a VM, or rejects its password. Trigger words - "metactf", "program.c.template", "build.zsh", "src_malware", "src_csp", "challenge_path", "Ch08Dbg".
---

# Create a MetaCTF challenge

> **Paths** are relative to the SecGen repository root (or your worktree of it).
> From a parent workspace, prefix them, e.g. `SecGen/modules/...`.

A MetaCTF challenge is C source compiled **on each VM during provisioning**, so
every student build has different secrets. The challenge is a directory holding
a template and a build script. Puppet builds everything, then installs the ones
the scenario selects as setgid binaries beside a flag file.

Below, `$M` is `modules/utilities/unix/ctf/metactf` and `$R` is `$M/files/repository`.

## How a challenge reaches a student

1. `$M/manifests/install.pp` copies `$R` to `/opt/metactf` and runs `make` in
   `src_angr`, `src_csp`, `src_malware` and `src_sse`. **Every** challenge is
   built on every metactf VM, selected or not.
2. Each chapter Makefile finds challenges with `SUBDIRS = $(wildcard Ch*_*)` and
   runs `./build.zsh $(USERS)`. `USERS` comes from the category's `users` file,
   which holds `secgen 9999`, so the output is `obj/secgen/<directory name>`.
3. The scenario's `metactf_challenge` generator
   (`modules/generators/structured_content/metactf_challenge/secgen_local/local.rb`)
   looks the path up in an allow-list and emits name, path, flag and a random group.
4. `$M/manifests/configure.pp` calls `secgen_functions::install_setgid_binary`,
   placing the binary (mode 2775, random group) and `flag` (0760) in
   `/home/<user>/challenges/<name>/`.

Consequences:

- The directory name is the challenge name and the binary name. In `Ch01-08`
  style chapters it **must match `Ch*_*`** or make ignores it.
- A challenge that isn't in `local.rb` makes `build-project` exit with "Challenge
  declared by challenge_path is either invalid...".
- The `foreach` in the Makefile doesn't stop on failure, so a broken `build.zsh`
  shows up later as a missing binary in the setgid install, not as a build error.
- Build time is paid on every metactf VM. Keep builds quick.

## Files

```
$R/src_malware/Ch01-08/Ch08Dbg_Example/
  program.c.template   # C source with placeholders
  build.zsh            # executable; install.pp chmods */*/*.zsh as well
  helper.c             # optional build-time helper (precedent: Ch18PackUnp_UnpackGdb/protect.c)
```

Add any compiled helper's name to `$R/.gitignore` beside `obj` and `protect`.

## build.zsh

```zsh
#!/bin/zsh
SALT=`date +%N`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    AA=`echo $USER $SALT $BINNAME AA | sha512sum | base64 | head -1 | tr -d /=+ | cut -c 1-8`
    cat program.c.template | sed s/AAAAAA/$AA/ >! program.c
    gcc -m32 -o obj/$USER/$BINNAME program.c
  end
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
```

Randomisation rules:

- Derive every value from `$USER $SALT $BINNAME`, and add a label per value
  (`AA`, `S1`...) so two values from one build differ.
- Common recipes: 8 alphanumerics as above; hex with `sha512sum | cut -c 1-8`;
  decimal with `sha256sum | ... | tr a-f A-F` then `echo "ibase=16;$X" | bc`.
- Strip `/=+` from base64 output: `/` breaks the `sed` expression.
- `sed s/X/Y/` replaces the **first match on each line**. Use one placeholder per
  line, or add `g`. Use a placeholder that can't occur in the code (`AAAAAA`).
- `>!` is zsh for "overwrite despite noclobber".
- Tools must be installed by `install.pp` (zsh, build-essential, gcc-multilib,
  bc). `openssl` is used by some challenges. Don't assume anything else.
- Flags are the choice of challenge: `-m32` is the norm, `-O0` keeps the code
  readable, `-s` strips symbols, `-static` is for packed challenges.

## program.c.template conventions

Copy these from a neighbouring challenge rather than rewriting them:

- `char msg[]`: the banner shown at start. Check it matches the build: most
  templates are `-m32`, so `$rax`, `retq` and `$rbp` in a banner are wrong.
- `print_msg()` with its `/* Symbolic execution trap */` loop.
- `printflag()`, which opens `flag` relative to the working directory.
- Read input with `scanf` from stdin, print `Enter the password: `, then
  `Good Job.` and `printflag()`, or `Try again.`.

Reject empty and arbitrary input: `secgen_test/metactf.rb` feeds both.

### Keep the secret out of reach

- Filled-in `program.c` files stay in `/opt/metactf/...` at mode 0644 (checked on
  a Debian 12 build), and `include_c` also ships them to students. Treat that
  source as readable unless the module has since restricted the directory. Keeping
  only encoded data in `program.c` makes a leak harder to use, but seeds and
  encoded bytes can still be decoded, so restricting access is the real fix.
- Plain string constants are visible to `strings` and Ghidra. That's fine for
  intro levels; decide deliberately.
- If you want a challenge to need dynamic analysis, test that claim: try
  `strings`, `ltrace` and the decompiler against the built binary.

### Debuggers and setgid

ptrace drops the setgid privilege, so `printflag()` fails under gdb, GEF or
Ghidra's debugger. Students find the password in the debugger and then run the
binary normally. Sheets need to say so.

A gdb `watch` stops only when a value **changes**. If a challenge depends on
watchpoints, make sure each stage changes the watched bytes.

## Register and wire

Add the path to the matching list in `local.rb` (`src_malware` etc.) with a
difficulty of `easy`, `medium` or `hard`. Random selection by difficulty will
now include it too. In the scenario:

```xml
<generator type="metactf_challenge">
  <input into="challenge_path">
    <value>src_malware/Ch01-08/Ch08Dbg_Example</value>
  </input>
</generator>
```

## Verify

1. Logic, without a VM: fill in the template by hand, compile, try the right
   password, a wrong one and an empty one. Run it several times with new values.
   A host without `gcc-multilib` can drop `-m32` for this step only.
2. `ruby lib/CyBOK/validate_xml_all_scenarios.rb` and
   `ruby secgen.rb -s <scenario> build-project`.
3. Real build (`secgen-test-pipeline`): the module's `secgen_test` covers build,
   setgid, flag permissions and rejecting bad input for every selected challenge.
4. Solve it as a student on that VM, with the tools the sheet names.

## Public repo rule

`modules/` is public. Templates, build scripts and helpers are fine. Solvers,
walkthroughs and test scripts that reveal the method go in the private
SecGenPipeline repo under `tests/labs/<category>/<lab>/`.
