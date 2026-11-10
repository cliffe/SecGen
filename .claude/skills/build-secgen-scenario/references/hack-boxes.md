# Hack boxes: practice CTF scenarios for Hacktivity

A **hack box** is a small, self-contained CTF scenario that Hacktivity users
pick up on their own as a practice environment. There is no lab sheet and no
Hackerbot: the scenario `<description>` is the whole brief, so the box has to
make sense from that paragraph and a port scan. Each one teaches a short kill
chain (one remote foothold, then usually one privilege escalation) with a flag
at each step.

This file extends the main `SKILL.md`. Everything there still applies
(namespace, datastores, accounts, cleanup block, cheap validation); this file
adds the conventions specific to hack boxes and a checklist that catches the
problems the first seven boxes had.

> **No answers here.** SecGen is public. Describe a box by its modules and
> flags, as the scenario XML already does. Exploit commands, walkthroughs and
> solve scripts belong in SecGenPipeline `tests/labs/`, never in this repo.

## The reference boxes

The first seven hack boxes, all in `scenarios/ctf/`. Copy from the one closest
to what you are building.

| File | Shape | Chain (modules) | Flags |
|---|---|---|---|
| `easy_as_pi.xml` | Kali + target | `raspap_rce` → `sudo_root_awk` | 2 |
| `disastrous_development.xml` | Kali + target | `lucee_rce` (one shot) | 1 |
| `drupwned.xml` | Kali + target | `drupal_850` (encoded pre-leak + webroot) → `sudo_root_less` | 3 |
| `such_a_git.xml` | Kali + target | `gitlist_040` leaks creds → user login → `sudo_root_apt_get` | 4 |
| `rand_webapp_adv.xml` | Kali + target | `commando` webapp, hard SQLi/XSS/IDOR/cookie generators | 4 |
| `root_cron-trol.xml` | Desktop login | `cron_writable_script` (horizontal) → `cron_tar_wildcard` (root) | 2 |
| `container_escape.xml` | Desktop + second target | `nc_backdoor_docker_esc`, `nc_backdoor_chroot_esc` | 2 |

## Pick a shape

**A. Kali + target (the default).** The user gets a Kali attacker VM and one
target on the same subnet. Use it for any box whose first step is remote:
scan, find the service, exploit it. Five of the seven boxes use this shape.

**B. Desktop login.** One target VM; the user logs in to its desktop as a
low-privileged account whose password is printed in the description. Use it
only when the whole box is local privilege escalation, so there is nothing to
attack remotely. `root_cron-trol.xml` is the model.

**C. Desktop plus further targets.** The user's own desktop doubles as the
attack box and as the first target, with more targets on the subnet. It saves
a Kali VM but makes the box harder to reason about, because the user already
has a shell on one target. Prefer A unless a no-Kali box is a requirement.

## Scenario-level metadata

```xml
<name>Easy as Pi</name>                <!-- short, punny title shown on Hacktivity -->
<author>Full Name</author>
<description>...</description>         <!-- the whole brief: see below -->

<type>ctf</type>
<type>attack-ctf</type>
<type>pwn-ctf</type>                   <!-- only if the user gets a shell or root -->
<difficulty>easy</difficulty>

<CyBOK KA="..." topic="...">...</CyBOK>  <!-- one block per technique in the chain -->
<CyBOK KA="AB" topic="Models"><keyword>kill chains</keyword></CyBOK>
<CyBOK KA="MAT" topic="Malicious Activities by Malware"><keyword>cyber kill chain</keyword></CyBOK>
```

- **`<type>`**: `ctf` + `attack-ctf` on every box. Add `pwn-ctf` when the
  chain gives a shell or root (six of the seven do). A pure web box with no
  shell, like `rand_webapp_adv`, leaves it off.
- **`<difficulty>`**: the XSD accepts any string, and `scenarios/ctf/` already
  mixes `easy`, `low`, `medium`, `intermediate` and `hard`. For hack boxes use
  `easy`, `medium` or `hard`, and make it agree with the description (a box
  described as "the harder sibling" should not say `easy`).
- **CyBOK**: take the blocks from the modules' own `secgen_metadata.xml` for
  each step, and add the two kill-chain blocks when there is more than one step.
- **`<description>`**: write it with the `write-secgen-ctf-description` skill.
  It has to tell a user who sees nothing else:
  - what is exposed and roughly what kind of flaw it has, without naming the
    CVE, exploit or tool;
  - how many flags there are and roughly where each sits (home directory,
    webroot, root's home);
  - any credentials they are given up front (shape B: the desktop password);
  - nothing that contradicts the build: every step it mentions must exist in
    the XML, and every flag in the XML must be mentioned.

## Shape A: the attacker system

Use this block unchanged. It puts the `IP_addresses` datastore on the
attacker, gives the known `kali/kali` login, and installs the usual tools.

```xml
<system>
  <system_name>attack_vm</system_name>
  <base distro="Kali" name="MSF"/>

  <input into_datastore="IP_addresses">
    <!-- 0 attack_vm -->
    <network_ip system="attack_vm"/>
    <!-- 1 target -->
    <network_ip system="target"/>
  </input>

  <utility module_path=".*/parameterised_accounts">
    <input into="accounts">
      <value>{"username":"kali","password":"kali","super_user":"true","strings_to_leak":[],"leaked_filenames":[]}</value>
    </input>
  </utility>

  <utility module_path=".*/iceweasel">
    <input into="accounts">
      <value>{"username":"kali","password":"kali","super_user":"true","strings_to_leak":[],"leaked_filenames":[]}</value>
    </input>
    <input into="autostart"><value>false</value></input>
  </utility>

  <utility module_path=".*/kali_top10"/>
  <utility module_path=".*/kali_web"/>

  <network type="private_network"/>

  <input into_datastore="spoiler_admin_pass">
    <generator type="strong_password_generator"/>
  </input>
  <build type="cleanup">
    <input into="root_password"><datastore>spoiler_admin_pass</datastore></input>
  </build>
</system>
```

Notes:

- **Addresses**: use `<network_ip system="..."/>`, not literal
  `<value>172.16.0.x</value>` addresses. `easy_as_pi` and `drupwned` hard-code
  `172.16.0.2`/`.3` and pin each NIC to them. That works only while nothing
  else uses the range. `network_ip` lets SecGen (or `--network-ranges`) pick the
  subnet.
- Keep both systems on the default `private_network` (VLAN 1) so they share a
  subnet. Do not set `vlan` on a hack box.
- Put the attacker first. Every Kali + target box except `rand_webapp_adv`
  does, and it keeps index 0 = attacker, 1 = target.

## The target system

```xml
<system>
  <system_name>target</system_name>
  <base distro="Debian 12" type="desktop" name="KDE"/>

  <!-- step 1: remote foothold, unauthenticated -->
  <vulnerability module_path=".*/<foothold_module>">
    <input into="strings_to_leak"><generator type="flag_generator"/></input>
  </vulnerability>

  <!-- step 2: privilege escalation to root -->
  <vulnerability module_path=".*/<privesc_module>">
    <input into="strings_to_leak"><generator type="flag_generator"/></input>
  </vulnerability>

  <network type="private_network"/>
  <build type="cleanup">
    <input into="root_password"><datastore>spoiler_admin_pass</datastore></input>
  </build>
</system>
```

- **Base: Debian 12 KDE.** It is the only Linux target base that builds on
  Proxmox. The Debian 10 base (`debian_buster_desktop_kde`) is marked
  **oVirt only**, so `such_a_git` and `drupwned` cannot be built on the Proxmox
  pipeline as written. Before moving an older module onto Debian 12, check it
  provisions there (`secgen-test-pipeline`), because some were written for
  Buster.
- **Pin the base** with `distro`, `type` and `name`. `rand_webapp_adv`'s
  `<base platform="linux" type="server"/>` resolves today only because Debian 12
  is the only Linux base tagged `server`; a new base would make it random.
- **Name every module with `module_path`.** A practice box should build the
  same way every time. Randomise values (flags, usernames, passwords, the
  difficulty input of a webapp generator), not the vulnerabilities.
- **One flag per step**, each from a `flag_generator` passed into the module's
  `strings_to_leak` (or `strings_to_pre_leak` for an earlier, easier flag the
  module supports, as `drupal_850` and `gitlist_040` do). Check the fact names
  in the module's `secgen_metadata.xml`: an input the module does not read is
  dropped silently and the flag never lands.
- **Encoded flags** add a decode step without a new module: wrap the
  `flag_generator` in an encoder, e.g.
  `<encoder type="^(ascii|alpha)_reversible$" difficulty="low">` as in
  `drupwned`.

### Multi-step pivots through an account

When the chain crosses into a real user account (`such_a_git`):

1. Generate the username and password into datastores once.
2. Create the account with `parameterised_accounts`, leaking that step's flag
   into its home (`leaked_filenames` + `strings_to_leak`).
3. Leak the same datastores through the foothold module
   (`strings_to_leak`/`strings_to_pre_leak`), so the only way to learn the
   password is the step before.
4. Make the password resist guessing over SSH if the user should not be able to
   skip step 1: a `strong_password_generator`, or a `random_sanitised_word` long
   enough not to be in `rockyou`.

## Shape B: desktop login

Follow `root_cron-trol.xml`:

- One `<system>` on Debian 12 KDE, no Kali.
- A random username (`username_generator`) and a **fixed** password for the
  starting account, printed in the description. The existing boxes use
  `tiaspbiqe2r`; reuse it so users learn one practice password.
- `kde_minimal` with `autologin_user` set to that account and
  `autostart_konsole` true, so the user lands in a terminal without needing
  the username.
- Every other account gets a `strong_password_generator` password. The only
  way into it must be the intended escalation.
- Randomise file locations with `generators/random/random_file_path` where the
  module accepts one (`cron_location`), so the answer differs per build.

## Shape C: desktop plus targets

If you must use it, follow `container_escape.xml`, but do not copy the
Hackerbot plumbing it carries (see the checklist).

## Hack-box checklist

Run this as well as the main skill's achievable-pathway checklist. Each item
is a defect found in at least one of the first seven boxes.

**Reachable as briefed**

- [ ] The first step works from the attacker with no credentials, or with only
      the credentials the description prints.
- [ ] Every flag in the XML has a step in the description, and the number of
      flags matches what the description implies.
- [ ] `<difficulty>` and the description agree.
- [ ] `pwn-ctf` is present exactly when the chain gives a shell.

**No unintended shortcuts**

- [ ] No account the user is not meant to enter has a weak or default password
      (`container_escape` creates two accounts with password `test`).
- [ ] No `ssh_root_login`, `hackerbot_access_root_password` or other Hackerbot
      plumbing. These come from Hackerbot labs, which need a way in for the bot;
      a hack box has no bot, and they only add attack surface
      (`container_escape` carries both).
- [ ] Shape B and C: the starting account is not in `sudo`, `docker`, `lxd`,
      `disk` or `adm` unless that group is the intended step.
- [ ] A later flag cannot be read before the step meant to reveal it (check
      the owner and mode each module gives the flag file).

**Builds on the pipeline**

- [ ] Every base is Proxmox-capable (Debian 12 KDE, Kali MSF).
- [ ] IPs come from `network_ip`, not literal addresses.
- [ ] Every vulnerability module has a `secgen_test` with tier-3 coverage, so a
      build proves the chain works and not only that it provisioned. List
      `modules/.../<name>/secgen_test/` for each; note a test file whose name
      differs from its module (e.g. `sudo_root_less` ships
      `secgen_test/suid_root_less.rb`), since tooling that expects
      `<name>.rb` will miss it.
- [ ] Every system ends with the `spoiler_admin_pass` cleanup block, and one
      system produces that datastore.

## Workflow

1. Pick the shape and write the chain as a list of modules and flags (the
   table row above for your box).
2. Assemble the XML from the blocks in this file into
   `scenarios/ctf/<slug>.xml` (snake_case filename; the `<name>` can be a pun).
3. Validate cheaply: `xmllint` against `lib/schemas/scenario_schema.xsd`, then
   `ruby secgen.rb -s scenarios/ctf/<slug>.xml build-project` (main skill,
   "Validate cheaply").
4. Write the description with `write-secgen-ctf-description`.
5. Review with `review-secgen-scenario`, then run the checklist above.
6. Build and run the module tests on Proxmox with `secgen-test-pipeline`. Keep
   any solve script or walkthrough in SecGenPipeline `tests/labs/ctf/<slug>/`.
