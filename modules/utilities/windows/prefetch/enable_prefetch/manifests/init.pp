class enable_prefetch {
  # exec { 'add_prefetch_parameter_keys_to_registry':
  #   # command => 'C:\windows\system32\cmd.exe /C reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 3 /f',
  # }
  #
  # exec { 'add_prefetcher_keys_to_registry':
  #   require => Exec['add_prefetch_parameter_keys_to_registry'],
  #   command => 'C:\windows\system32\cmd.exe /C reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Prefetcher" /v MaxPrefetchFiles /t REG_DWORD /d 8192 /f',
  # }
  #
  # exec { 'enable_MMAgent -OperationAPI':
  #   require => Exec['add_prefetcher_keys_to_registry'],
  #   command => 'C:\windows\system32\cmd.exe /C Enable-MMAgent -OperationAPI',
  # }
  #
  # exec { 'start_sysmain':
  #   require => Exec['enable_MMAgent -OperationAPI'],
  #   command => 'C:\windows\system32\cmd.exe /C net start sysmain',
  # }

  exec { 'enable_prefetcher':
    command => 'C:\windows\system32\cmd.exe /C reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 3 /f',
  }

  exec { 'enable_superfetcher':
    command => 'C:\windows\system32\cmd.exe /C reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 1 /f',
  }

  exe { 'reboot':
    command => 'C:\windows\system32\cmd.exe /C shutdown /g /t 0',
  }

}