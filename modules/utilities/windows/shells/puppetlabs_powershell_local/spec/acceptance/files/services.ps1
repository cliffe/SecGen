$temp = "C:/temp"
if(!(Test-Path $temp)){
    mkdir $temp
}
Get-Service *puppet* | Export-Csv "$temp\services.csv"
