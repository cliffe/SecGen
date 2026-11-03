Labtainers-master is master from  https://github.com/mfthomps/Labtainers

Current copy: v1.4.4n, upstream commit c257905f (2026-09-26), synced 2026-10-23.

# To update the version in SecGen
Download ZIP from github (or clone it), and extract over Labtainers-master,
removing files that upstream has deleted, e.g.:

```bash
rsync -a --delete --exclude=.git --exclude=.gitignore --exclude=.gitattributes --exclude=.DS_Store \
  --exclude=/tool-src/capinout/capinout --exclude=/scripts/labtainer-student/lab_sys/usr/sbin/capinout \
  Labtainers/ Labtainers-master/
```

Keep the two compiled `capinout` binaries: upstream does not ship them, and
`install.pp` falls back to them if `mkit.sh` fails on the VM.

install latex locally:
```bash
sudo apt install texlive-latex-base texlive-latex-recommended  texlive-latex-extra
```

In each directory in docs/ run `make` to build the pdfs in place. Upstream
sometimes changes a lab's .tex without rebuilding its pdf, so compare them.
