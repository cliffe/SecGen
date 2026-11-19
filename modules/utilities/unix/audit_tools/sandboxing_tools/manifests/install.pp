# Installs bubblewrap and Firejail from the Debian archive.
class sandboxing_tools::install {
  ensure_packages(['bubblewrap', 'firejail'])
}
