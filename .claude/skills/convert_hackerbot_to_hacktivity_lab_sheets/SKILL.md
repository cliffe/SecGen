---
name: convert_hackerbot_to_hacktivity_lab_sheets
description: Convert a SecGen Hackerbot lab sheet (a hackerbot_config generator's ERB templates, historically rendered and hosted locally by Apache on the hackerbot_server VM) into a static, GitHub-hosted Hacktivity lab sheet under HacktivityLabSheets/_labs/. Use when asked to "convert this hackerbot lab", "move the lab sheet to Hacktivity", "de-parameterise a lab sheet", or when a scenario of type hackerbot-lab needs its sheet published outside the VM. As of this writing every existing hackerbot_config generator has been converted and Apache has been retired from the module entirely; this skill now applies to any newly authored hackerbot lab.
---

# Converting a Hackerbot lab sheet to a Hacktivity lab sheet

The SecGen Hackerbot labs generate their lab sheet at build time: a
`hackerbot_config` generator renders an XML bot config from ERB, and the markdown
sheet is **extracted from that XML** and served by Apache on the
`hackerbot_server` VM. Moving the sheet to
`HacktivityLabSheets` means reassembling it from its sources, removing
everything that was per-instance, and rewriting it in the Hacktivity
highlighting format.

Two repos are involved:

- SecGen: `/home/cliffe/Files/Projects/Code/SecGen`
- Hacktivity lab sheets: `/home/cliffe/Files/Projects/Code/HacktivityLabSheets`

## Before you start: how the sheet is actually assembled

Do not convert from the `.md.erb` files alone. They are only part of the sheet.

`lib/objects/local_hackerbot_config_generator.rb#generate_lab_sheet` builds the
markdown by walking the *rendered* bot config XML:

- `tutorial_info/tutorial` becomes the opening section
- each `<attack>`'s `<tutorial>` is emitted in attack order
- then, **synthesised per attack and present in no template**:
  - `#### <botname> Attack #N`
  - a "you can skip the bot to here, by saying **goto N**" line
  - the bot's `<prompt>` as a blockquote
  - "when you are ready for the bot to complete the action/attack, ==say 'ready'=="
  - if the attack has a `<quiz>`, an "answer *YOURANSWER*" line
  - "Don't forget to ==save and submit any flags!=="
- `tutorial_info/footer` closes it

So a chunk of every sheet exists only in Ruby. It must be written by hand into
the static version.

Also check which templates are actually reachable. `grep -n 'ERB.new\|File.read' <config>.xml.erb`
against `ls templates/*.md.erb` — unreferenced templates are dead weight in that
module.

Before treating an unreferenced template as content to reinstate, **check the
sibling generators**. The `hackerbot_config/` directory has ~28 generators and
they were built by copying each other's `templates/` wholesale, so a template
unused in one lab is usually live in another. `integrity_protection` carries
five unrendered markdown templates plus a 959-line `integrity.md`; all of them
are rendered by `integrity_detection`, which is a separate lab covering the
detection half of the topic. So they are copy-paste residue here, not missing
content. Confirm with:

```bash
grep -rln '<template name>' modules/generators/structured_content/hackerbot_config/*/templates/*.xml.erb
```

Drop residue from the converted sheet. Raise it with the user only where a
template is unused *everywhere*.

## Step 1 — walk the sources

Do not render. Read `templates/<lab>.xml.erb` top to bottom and build the sheet's
running order from it; the ERB is more informative than its output, because a
`<%= $main_user %>` marks a parameterised spot exactly, where a rendered username
has to be hunted for.

Three passes:

1. **Running order.** Every `ERB.new(File.read ... )` / `File.read` line in the
   `.xml.erb`, in source order, is one section of the sheet. Interleave the
   synthesised Attack blocks (above) at each `<attack>`, in element order. That
   is the complete table of contents.
2. **Parameterised values.** The `<% ... %>` header block at the top of the
   `.xml.erb` defines every global the templates interpolate. Read it once and
   note what each resolves to and where it comes from — scenario input, a
   generator default, or chance. Then `grep -n '<%=' templates/*.md.erb` for the
   usage sites.
3. **Randomised values.** In that same header, anything built with
   `SecureRandom`, `.sample`, or `rand` differs per instance and needs a
   placeholder rather than a fixed value. In `integrity_protection` that is
   `$example_file` (`$files.sample`) and the `/tmp/<%= $file %>` in attack 1's
   prompt (`SecureRandom.hex(2)`). Note that `.sample` on a one-element array is
   effectively fixed — check the array's real contents before calling a value
   randomised.

Read the `.md.erb` bodies for prose, and the `<prompt>` / `<quiz>` elements for
the bot-facing text that the synthesised blocks quote.

The footer (`tutorial_info/footer`) is emitted after **all** attacks. Keep it
there — it is easy to slip a footer section in next to thematically-related
content and split it across the last attack.

## Step 2 — de-parameterise

Every parameterised value needs an explicit replacement strategy. The rule: a static sheet
cannot know an instance's values, so it must either tell the student to look
them up, or have the lab create the value itself.

| What | Strategy |
|---|---|
| `$main_user` (randomised username) | Add an early numbered step: read it from the VM (`whoami`). Then use `==edit: your username==` in commands, or `$USER` where the command allows it. |
| `$second_user` | Same: a step to list it (`ls /home`), then a placeholder. |
| Sampled filenames (`$example_file`, `$log_file`) | Prefer having the lab *create* a fixed file it then operates on. Only fall back to "the file Hackerbot names" where the attack genuinely targets a pre-seeded file. **Do not replace an absolute `/home/<user>/...` path with `~` inside `sudo bash -c '...'`** — the `~` is then expanded by root's shell and means `/root`, silently breaking the exercise. Use `$HOME` in double quotes (`sudo bash -c "... > $HOME/file"`), which your own shell expands before `sudo` runs. Bare `~` is fine anywhere the student's own shell does the expanding, including `sudo chattr +i ~/file`. |
| `/tmp/<random hex>` in a bot prompt | "the filename Hackerbot gives you in the chat". |
| Flags | Never appear in the sheet: `$flags.pop` is only ever used inside `<message>` / `<shell_fail_message>`, which the sheet does not include. Nothing to do. |
| Hardcoded constants (e.g. the password `tiaspbiqe2r`) | Keep as-is; these are scenario constants, not per-instance. |

**Summarise the bot's `<prompt>` text, never reproduce it.** The synthesised
Attack blocks quote what Hackerbot says. Write each `> Hackerbot:` block as a
paraphrase or a very short summary of the task — one or two sentences naming
the technique and the goal — not the prompt's wording.

The reason is maintenance, and it decides the edge cases. Hackerbot delivers the
authoritative prompt in the chat, live, every time. Anything the sheet restates
is a second copy that has to be updated whenever the challenge changes, and
nothing will catch it when it is not. So keep what is stable — the technique
being taught, the shape of the task — and leave the specifics to the chat:
exact filenames, generated paths, alert strings, target ports, and anything
built from `SecureRandom`. Point at the bot for those ("the file Hackerbot
gives you in the chat").

Do not wrap these blocks in quotation marks. They are summaries, and quoting
them implies a fidelity to the bot's wording that the sheet does not keep.

## Step 3 — strip the VM-local assumptions

The sheet used to be served *from* the lab network and read *inside* the VM.
Now it is on the public web and the student reads it on their host, while the
VMs have **no internet access at all**. Anything that assumed those two were the
same machine breaks. Check for and fix each of these:

- **Links or downloads the sheet expects the VM to fetch.** The sheet can no
  longer hand a file to the VM by being clicked in it. The clearest example in
  the tree is `dead_analysis/templates/intro.md.erb:64`, an
  `<a href="data:...">Click here to download the md5 hashes...</a>` that only
  works because the browser rendering it is inside the target VM; from a host
  browser it saves to the wrong machine entirely. Such content has to move into
  the VM at build time (a file placed by the scenario) or be typed out in the
  sheet. Likewise drop any "if you had an internet connection..." hedging —
  make it unambiguous.
- **Long code the student was expected to copy from the page.** With the sheet
  on the host, copying into the VM depends on clipboard sharing you cannot
  assume. Where a template has the student save a script (e.g.
  `fim.md.erb`'s `checker.pl`), consider having the scenario place the file in
  the VM instead, and have the sheet point at it.
- **Relative asset paths.** `![small-right](images/skullandusb.svg)` resolved
  against the Apache docroot. Source files live in
  `modules/utilities/unix/hackerbot/files/www/images/`. Copy them to
  `HacktivityLabSheets/assets/images/<category>/<lab_slug>/` and reference them
  as `{{ site.baseurl }}/assets/images/<category>/<lab_slug>/<file>`.
  **Exception: the Hackerbot skull (`skullandusb.svg`) — do not copy it.** It is
  already shared at `assets/images/shared/skullandusb.svg` and is emitted by the
  `hackerbot-intro.md` include (see Step 4). Copying it per-lab re-creates the
  duplication that include exists to remove.
- **Styling links** (`css/github-markdown.css`, code-prettify). Delete; Jekyll
  supplies its own.
- **Implicit "you are on the desktop VM"**. Anywhere the sheet says "Open
  Pidgin" or bare "Run:", make the machine explicit with `==VM: On the desktop
  VM==`.
- **`![small]` / `![small-right]` sizing hints** are a hackerbot-template
  convention. Check whether the Hacktivity theme honours them; if not, drop them.

## Step 4 — convert to Hacktivity format

Read `/home/cliffe/Files/Projects/Code/HacktivityLabSheets/_labs/example_highlighting_guide.md`
in full and follow it. The most common conversions in Hackerbot sheets:

- **Untyped highlights.** Hackerbot sheets use bare `==Run:==`, `==Set the 'i'
  flag==`. Hacktivity needs a type: `==action: ...==`. Count them first with
  `grep -o '==[^=]*==' templates/*.md.erb | grep -cvE '==(action|tip|hint|warning|VM|question|edit):'`
  so none are missed — expect a few dozen per sheet.
- `==Lab book question: ...==` / `==Log Book question: ...==` → `> Question: ...`
- The synthesised "save and submit any flags" and per-attack challenge text →
  `> Flag: ...`
- **The synthesised blocks carry untyped highlights of their own** — `==say
  'ready'==` and `==save and submit any flags!==` come out of the Ruby that way.
  Type them (`==action: ...==`) like any other. Re-run the count above on the
  finished markdown, not just the templates, to catch these.
- Commands into fenced ` ```bash ` blocks with pipes escaped as `\|`.
- Headings: strip bold, add `{#anchor-slug}`.
- Troubleshooting or explanation immediately following a command → `> Note: ...`

Front matter maps almost mechanically from the scenario XML:

| Front matter | Source in `scenarios/**/<lab>.xml` |
|---|---|
| `title` | `<name>` (or the config template's `tutorial_info/title`, usually better) |
| `author` | `<author>`, as a list |
| `license` | `"CC BY-SA 4.0"` — matches the sheet's own licence footer |
| `description` | one-sentence summary |
| `overview` | the `<description>` body, as a `\|` block |
| `tags`, `categories` | `categories` must match the `_labs/` subdirectory |
| `type` | `<type>` elements, e.g. `["ctf-lab", "hackerbot-lab", "lab-sheet"]` |
| `difficulty` | `<difficulty>` |
| `cybok` | each `<CyBOK KA= topic=>` with its `<keyword>`s |

**Drop the sheet's own `## License` section.** The licence belongs in the front
matter (`license: "CC BY-SA 4.0"`, which every lab in `_labs/` uses) and the
layout renders it; no converted lab carries a License heading in its body.
Dropping it usually orphans the Leeds Beckett logo, which appears nowhere else
— remove its image reference, its link definition, and the copied asset file
rather than leaving a dangling reference.

**Do not hand-write the "Meet Hackerbot!" section — include it.** Every
Hackerbot lab opens with the same blurb (skull image, what Hackerbot does,
optionally a Pidgin warm-up, the `goto N` tip, "Work through the below
exercises"). That text lives once, in
`HacktivityLabSheets/_includes/hackerbot-intro.md`. Emit a call to it instead,
immediately after the "Getting started" material and before the first content
section:

```liquid
{% include hackerbot-intro.md role="task you to monitor the network and will attack your systems" pidgin="full" %}
```

- `role` — the clause following "a chatbot who will". Take the wording from the
  generator's own `tutorial_info/tutorial` text so it describes *this* lab.
  Omit it and it defaults to "attack your system".
- `pidgin` — `"full"` for the first Hackerbot lab a student meets (lists the
  opening messages to try), `"hello"` for a short prompt, omitted for later labs
  where the student already knows how to reach the bot.

The include supplies its own heading, image, tip and trailing `---`. Do not add
a `## Meet Hackerbot!` heading, a `![Skull and USB stick]` reference, or a
`[skullandusb]:` link definition around it — that is what the include replaces.
If a lab's source genuinely has no Hackerbot introduction (some later labs in a
series assume the earlier ones), still emit the include: the labs are meant to
be consistent, and a student may start anywhere.

Changing the shared wording for every lab means editing that one include; a
change made in a lab sheet instead will be silently inconsistent with the other
seven.

Write to `_labs/<category>/<n>_<slug>.md`, matching the numbering already in
that directory.

## Step 5 — write back to SecGen

Conversion is not finished when the markdown lands. The scenario still points
students at the VM-hosted copy:

- **Do not repoint the in-VM browser at the Hacktivity URL.** The lab VMs have
  no internet access, so nothing inside them can reach the published sheet. The
  student reads it on their host browser and works in the VM alongside it.
- **Consider removing the `iceweasel` utility from the scenario**, along with
  its `start_page`, `autostart` and `accounts` inputs. In a sheet-only setup —
  `start_page` pointing at `<datastore access="1">IP_addresses</datastore>`, the
  hackerbot_server — displaying the sheet was the browser's entire purpose, and
  it is now dead weight. **Check first**: a scenario may want a browser for the
  lab itself (a web target, a local service, a proxy exercise), in which case
  keep the module and only drop or repoint `start_page`. Decide per scenario;
  do not remove it by reflex.
- **Add the `<lab_sheet_url>`** to the scenario, matching the format the
  already-converted labs use (see `scenarios/labs/introducing_attacks/`):

  ```xml
  <lab_sheet_url>https://cliffe.github.io/HacktivityLabSheets/labs/<category>/<slug>/</lab_sheet_url>
  ```

  It is a single optional element (`lib/schemas/scenario_schema.xsd:13`) and
  goes directly after `</description>`. The URL is built from the Jekyll
  permalink `/:collection/:categories/:name/` (`_config.yml`), so:
  `<category>` is the front matter `categories` value (underscores kept), and
  `<slug>` is the `_labs/` filename with underscores turned to hyphens and
  `.md` dropped — `_labs/introducing_attacks/5_scanning.md` becomes
  `.../labs/introducing_attacks/5-scanning/`. The trailing slash matters.

  `lib/CyBOK/template_CyBOK_scenarios.md.erb:58` picks this up, so the CyBOK
  scenario tables link the sheet automatically once it is set.
- Update the `<description>`'s "The labsheet is available once you claim a set
  of VMs" sentence, which is no longer true.
- If the `hackerbot_configs` input still carries `into_datastore="hackerbot_instructions"`
  from before the Apache retirement, drop that attribute, keeping `into=`:

  ```xml
  <input into="hackerbot_configs">
  ```

  Nothing consumes that datastore any more — Apache, `html_lab_sheet`, and the
  `instructions.html` project file it used to produce have all been retired
  from the hackerbot module. The attribute is inert either way, but a new
  conversion shouldn't add it.
- Do **not** add an `externally_hosted_lab_sheet` input. That flag existed to
  choose between a full locally-hosted copy of the sheet and a short
  placeholder page; both code paths, and the flag itself, have been removed
  from the hackerbot module along with Apache. `<service type="httpd"/>` is no
  longer part of the hackerbot module's requirements either.
- Leave the bot config alone. Only the sheet moves; attacks, conditions and
  flags stay in SecGen.
- The `tutorial`/`tutorial_info` elements in the ERB templates are unused
  scaffolding now (the bot never read them — `hackerbot.rb` has no reference
  to `tutorial`, and its schema validation is commented out) but were left in
  place across the ~28 generators; removing them per-generator is a separate,
  optional cleanup, not part of converting a single lab.

## Report at the end

State plainly:

- which templates were dead and what you did about them
- every value you de-parameterised, and the strategy used for each
- anything you could **not** de-parameterise, with the reason
- assets copied, and the Step 5 SecGen edits still outstanding
