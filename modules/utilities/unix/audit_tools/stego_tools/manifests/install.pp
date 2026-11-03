class stego_tools::install{
  # Debian ships exiftool as libimage-exiftool-perl; there is no "exiftool" package
  ensure_packages(["exif", "libimage-exiftool-perl", "steghide"])
}
