class wifi_mouse_windows::install {
	Exec { path => ["C:\\Windows"] }

	file { 'C:\vc_redist.x86.exe':
		source => 'puppet:///modules/wifi_mouse_windows/vc_redist.x86.exe',
	} ->
	exec { 'install_c++_redistributable':
		command => 'C:\\vc_redist.x86.exe /install /quiet /norestart',
	} ->
	file { 'C:\wireless_mouse_installer.exe':
		source => 'puppet:///modules/wifi_mouse_windows/wireless_mouse_installer.exe',
	} ->
	exec { 'install_wireless_mouse':
		command => 'C:\\Windows\\system32\\cmd.exe /c "start timeout /t 120 taskkill /b C:\\wireless_mouse_installer.exe /VERYSILENT /NORESTART"',
		timeout => 1200,
	} ->
	file { 'C:\\create-firewall-rule.ps1':
		source => 'puppet:///modules/wifi_mouse_windows/create-firewall-rule.ps1'
	} ->
	exec { 'create-firewall-rule':
		command => 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -noexit -file "C:\\create-firewall-rule.ps1"',
	}
}
