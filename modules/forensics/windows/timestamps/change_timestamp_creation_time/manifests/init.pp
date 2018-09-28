# $file_path = 'C:\Users\vagrant\Desktop\Hello.txt'
# $file_time = '11/25/2000 11:12:13'

class change_timestamp_creation_time ($file_path, $file_time) {
  exec { 'change_creation_time':
    command   => "$((ls ${file_path}).CreationTime = '${file_time}')",
    provider  => powershell,
  }
}