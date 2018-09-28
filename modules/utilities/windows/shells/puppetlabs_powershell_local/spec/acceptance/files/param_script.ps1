Param(
	[String] $ProcessName,
	[String] $fileOut
)
$processes = Get-Process $ProcessName
New-Item $fileOut -ItemType File
$processes | Out-File $fileOut -Encoding UTF8
