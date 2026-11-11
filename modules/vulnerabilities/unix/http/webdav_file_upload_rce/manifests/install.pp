# Composition-only module. The WebDAV collection and the randomly-selected
# execution enabler (php or cgi) are pulled in and configured by their own
# modules via <requires> in secgen_metadata.xml; this module adds no resources
# of its own. The empty class exists only so the module has a manifest to apply.
class webdav_file_upload_rce::install {
}
