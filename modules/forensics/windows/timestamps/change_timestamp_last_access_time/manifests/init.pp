# $file_path = 'C:\Users\vagrant\Desktop\Hello.txt'
# $file_time = '11/25/2000 11:12:13'

class change_timestamp_last_access_time ($file_path, $file_time) {
  exec { 'change_last_access_time':
    command   => "$((ls ${file_path}).LastAccessTime = '${file_time}')",
    provider  => powershell,
  }
}