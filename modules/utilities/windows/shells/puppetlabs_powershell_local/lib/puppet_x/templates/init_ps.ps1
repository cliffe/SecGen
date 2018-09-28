[CmdletBinding()]
param (
  [Parameter(Mandatory = $true)]
  [String]
  $NamedPipeName,

  [Parameter(Mandatory = $false)]
  [Switch]
  $EmitDebugOutput = $False,

  [Parameter(Mandatory = $false)]
  [System.Text.Encoding]
  $Encoding = [System.Text.Encoding]::UTF8
)

$script:EmitDebugOutput = $EmitDebugOutput
# Necessary for [System.Console]::Error.WriteLine to roundtrip with UTF-8
[System.Console]::OutputEncoding = $Encoding

$hostSource = @"
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.IO;
using System.Management.Automation;
using System.Management.Automation.Host;
using System.Security;
using System.Text;
using System.Threading;

namespace Puppet
{
  public class PuppetPSHostRawUserInterface : PSHostRawUserInterface
  {
    public PuppetPSHostRawUserInterface()
    {
      buffersize      = new Size(120, 120);
      backgroundcolor = ConsoleColor.Black;
      foregroundcolor = ConsoleColor.White;
      cursorposition  = new Coordinates(0, 0);
      cursorsize      = 1;
    }

    private ConsoleColor backgroundcolor;
    public override ConsoleColor BackgroundColor
    {
      get { return backgroundcolor; }
      set { backgroundcolor = value; }
    }

    private Size buffersize;
    public override Size BufferSize
    {
      get { return buffersize; }
      set { buffersize = value; }
    }

    private Coordinates cursorposition;
    public override Coordinates CursorPosition
    {
      get { return cursorposition; }
      set { cursorposition = value; }
    }

    private int cursorsize;
    public override int CursorSize
    {
      get { return cursorsize; }
      set { cursorsize = value; }
    }

    private ConsoleColor foregroundcolor;
    public override ConsoleColor ForegroundColor
    {
      get { return foregroundcolor; }
      set { foregroundcolor = value; }
    }

    private Coordinates windowposition;
    public override Coordinates WindowPosition
    {
      get { return windowposition; }
      set { windowposition = value; }
    }

    private Size windowsize;
    public override Size WindowSize
    {
      get { return windowsize; }
      set { windowsize = value; }
    }

    private string windowtitle;
    public override string WindowTitle
    {
      get { return windowtitle; }
      set { windowtitle = value; }
    }

    public override bool KeyAvailable
    {
        get { return false; }
    }

    public override Size MaxPhysicalWindowSize
    {
        get { return new Size(165, 66); }
    }

    public override Size MaxWindowSize
    {
        get { return new Size(165, 66); }
    }

    public override void FlushInputBuffer()
    {
      throw new NotImplementedException();
    }

    public override BufferCell[,] GetBufferContents(Rectangle rectangle)
    {
      throw new NotImplementedException();
    }

    public override KeyInfo ReadKey(ReadKeyOptions options)
    {
      throw new NotImplementedException();
    }

    public override void ScrollBufferContents(Rectangle source, Coordinates destination, Rectangle clip, BufferCell fill)
    {
      throw new NotImplementedException();
    }

    public override void SetBufferContents(Rectangle rectangle, BufferCell fill)
    {
      throw new NotImplementedException();
    }

    public override void SetBufferContents(Coordinates origin, BufferCell[,] contents)
    {
      throw new NotImplementedException();
    }
  }

  public class PuppetPSHostUserInterface : PSHostUserInterface
  {
    private PuppetPSHostRawUserInterface _rawui;
    private StringBuilder _sb;
    private StringWriter _errWriter;
    private StringWriter _outWriter;

    public PuppetPSHostUserInterface()
    {
      _sb = new StringBuilder();
      _errWriter = new StringWriter(new StringBuilder());
      // NOTE: StringWriter / StringBuilder are not technically thread-safe
      // but PowerShell Write-XXX cmdlets and System.Console.Out.WriteXXX
      // should not be executed concurrently within PowerShell, so should be safe
      _outWriter = new StringWriter(_sb);
    }

    public override PSHostRawUserInterface RawUI
    {
      get
      {
        if ( _rawui == null){
          _rawui = new PuppetPSHostRawUserInterface();
        }
        return _rawui;
      }
    }

    public void ResetConsoleStreams()
    {
      System.Console.SetError(_errWriter);
      System.Console.SetOut(_outWriter);
    }

    public override void Write(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string value)
    {
      _sb.Append(value);
    }

    public override void Write(string value)
    {
      _sb.Append(value);
    }

    public override void WriteDebugLine(string message)
    {
      _sb.AppendLine("DEBUG: " + message);
    }

    public override void WriteErrorLine(string value)
    {
      _sb.AppendLine(value);
    }

    public override void WriteLine(string value)
    {
      _sb.AppendLine(value);
    }

    public override void WriteVerboseLine(string message)
    {
      _sb.AppendLine("VERBOSE: " + message);
    }

    public override void WriteWarningLine(string message)
    {
      _sb.AppendLine("WARNING: " + message);
    }

    public override void WriteProgress(long sourceId, ProgressRecord record)
    {
    }

    public string Output
    {
      get
      {
        _outWriter.Flush();
        string text = _outWriter.GetStringBuilder().ToString();
        _outWriter.GetStringBuilder().Length = 0; // Only .NET 4+ has .Clear()
        return text;
      }
    }

    public string StdErr
    {
      get
      {
        _errWriter.Flush();
        string text = _errWriter.GetStringBuilder().ToString();
        _errWriter.GetStringBuilder().Length = 0; // Only .NET 4+ has .Clear()
        return text;
      }
    }

    public override Dictionary<string, PSObject> Prompt(string caption, string message, Collection<FieldDescription> descriptions)
    {
      throw new NotImplementedException();
    }

    public override int PromptForChoice(string caption, string message, Collection<ChoiceDescription> choices, int defaultChoice)
    {
      throw new NotImplementedException();
    }

    public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName)
    {
      throw new NotImplementedException();
    }

    public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName, PSCredentialTypes allowedCredentialTypes, PSCredentialUIOptions options)
    {
      throw new NotImplementedException();
    }

    public override string ReadLine()
    {
      throw new NotImplementedException();
    }

    public override SecureString ReadLineAsSecureString()
    {
      throw new NotImplementedException();
    }
  }

  public class PuppetPSHost : PSHost
  {
    private Guid _hostId = Guid.NewGuid();
    private bool shouldExit;
    private int exitCode;

    private readonly PuppetPSHostUserInterface _ui = new PuppetPSHostUserInterface();

    public PuppetPSHost () {}

    public bool ShouldExit { get { return this.shouldExit; } }
    public int ExitCode { get { return this.exitCode; } }
    public void ResetExitStatus()
    {
      this.exitCode = 0;
      this.shouldExit = false;
    }
    public void ResetConsoleStreams()
    {
      _ui.ResetConsoleStreams();
    }

    public override Guid InstanceId { get { return _hostId; } }
    public override string Name { get { return "PuppetPSHost"; } }
    public override Version Version { get { return new Version(1, 1); } }
    public override PSHostUserInterface UI
    {
      get { return _ui; }
    }
    public override CultureInfo CurrentCulture
    {
        get { return Thread.CurrentThread.CurrentCulture; }
    }
    public override CultureInfo CurrentUICulture
    {
        get { return Thread.CurrentThread.CurrentUICulture; }
    }

    public override void EnterNestedPrompt() { throw new NotImplementedException(); }
    public override void ExitNestedPrompt() { throw new NotImplementedException(); }
    public override void NotifyBeginApplication() { return; }
    public override void NotifyEndApplication() { return; }

    public override void SetShouldExit(int exitCode)
    {
      this.shouldExit = true;
      this.exitCode = exitCode;
    }
  }
}
"@

Add-Type -TypeDefinition $hostSource -Language CSharp
$global:DefaultWorkingDirectory = (Get-Location -PSProvider FileSystem).Path

#this is a string so we can import into our dynamic PS instance
$global:ourFunctions = @'
function Get-ProcessEnvironmentVariables
{
  $processVars = [Environment]::GetEnvironmentVariables('Process').Keys |
    % -Begin { $h = @{} } -Process { $h.$_ = (Get-Item Env:\$_).Value } -End { $h }

  # eliminate Machine / User vars so that we have only process vars
  'Machine', 'User' |
    % { [Environment]::GetEnvironmentVariables($_).GetEnumerator() } |
    ? { $processVars.ContainsKey($_.Name) -and ($processVars[$_.Name] -eq $_.Value) } |
    % { $processVars.Remove($_.Name) }

  $processVars.GetEnumerator() | Sort-Object Name
}

function Reset-ProcessEnvironmentVariables
{
  param($processVars)

  # query Machine vars from registry, ensuring expansion EXCEPT for PATH
  $vars = [Environment]::GetEnvironmentVariables('Machine').GetEnumerator() |
    % -Begin { $h = @{} } -Process { $v = if ($_.Name -eq 'Path') { $_.Value } else { [Environment]::GetEnvironmentVariable($_.Name, 'Machine') }; $h."$($_.Name)" = $v } -End { $h }

  # query User vars from registry, ensuring expansion EXCEPT for PATH
  [Environment]::GetEnvironmentVariables('User').GetEnumerator() | % {
      if ($_.Name -eq 'Path') { $vars[$_.Name] += ';' + $_.Value }
      else
      {
        $value = [Environment]::GetEnvironmentVariable($_.Name, 'User')
        $vars[$_.Name] = $value
      }
    }

  $processVars.GetEnumerator() | % { $vars[$_.Name] = $_.Value }

  Remove-Item -Path Env:\* -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Recurse

  $vars.GetEnumerator() | % { Set-Item -Path "Env:\$($_.Name)" -Value $_.Value }
}

function Reset-ProcessPowerShellVariables
{
  param($psVariables)
  $psVariables | %{
    $tempVar = $_
    if(-not(Get-Variable -Name $_.Name -ErrorAction SilentlyContinue)){
      New-Variable -Name $_.Name -Value $_.Value -Description $_.Description -Option $_.Options -Visibility $_.Visibility
    }
  }
}
'@

function Invoke-PowerShellUserCode
{
  [CmdletBinding()]
  param(
    [String]
    $Code,

    [Int]
    $TimeoutMilliseconds,

    [String]
    $WorkingDirectory
  )

  if ($global:runspace -eq $null){
    # CreateDefault2 requires PS3
    if ([System.Management.Automation.Runspaces.InitialSessionState].GetMethod('CreateDefault2')){
      $sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault2()
    }else{
      $sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    }

    $global:puppetPSHost = New-Object Puppet.PuppetPSHost
    $global:runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($global:puppetPSHost, $sessionState)
    $global:runspace.Open()
  }

  try
  {
    $ps = $null
    $global:puppetPSHost.ResetExitStatus()
    $global:puppetPSHost.ResetConsoleStreams()

    if ($PSVersionTable.PSVersion -ge [Version]'3.0') {
      $global:runspace.ResetRunspaceState()
    }

    $ps = [System.Management.Automation.PowerShell]::Create()
    $ps.Runspace = $global:runspace
    [Void]$ps.AddScript($global:ourFunctions)
    $ps.Invoke()

    if ([string]::IsNullOrEmpty($WorkingDirectory)) {
      [Void]$ps.Runspace.SessionStateProxy.Path.SetLocation($global:DefaultWorkingDirectory)
    } else {
      if (-not (Test-Path -Path $WorkingDirectory)) { Throw "Working directory `"$WorkingDirectory`" does not exist" }
      [Void]$ps.Runspace.SessionStateProxy.Path.SetLocation($WorkingDirectory)
    }

    if(!$global:environmentVariables){
      $ps.Commands.Clear()
      $global:environmentVariables = $ps.AddCommand('Get-ProcessEnvironmentVariables').Invoke()
    }

    if($PSVersionTable.PSVersion -le [Version]'2.0'){
      if(!$global:psVariables){
        $global:psVariables = $ps.AddScript('Get-Variable').Invoke()
      }

      $ps.Commands.Clear()
      [void]$ps.AddScript('Get-Variable -Scope Global | Remove-Variable -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue')
      $ps.Invoke()

      $ps.Commands.Clear()
      [void]$ps.AddCommand('Reset-ProcessPowerShellVariables').AddParameter('psVariables', $global:psVariables)
      $ps.Invoke()
    }

    $ps.Commands.Clear()
    [Void]$ps.AddCommand('Reset-ProcessEnvironmentVariables').AddParameter('processVars', $global:environmentVariables)
    $ps.Invoke()

    # we clear the commands before each new command
    # to avoid command pollution
    $ps.Commands.Clear()
    [Void]$ps.AddScript($Code)

    # out-default and MergeMyResults takes all output streams
    # and writes it to the PSHost we create
    # this needs to be the last thing executed
    [void]$ps.AddCommand("out-default");

    # if the call operator & established an exit code, exit with it
    [Void]$ps.AddScript('if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }')

    if($PSVersionTable.PSVersion -le [Version]'2.0'){
      $ps.Commands.Commands[0].MergeMyResults([System.Management.Automation.Runspaces.PipelineResultTypes]::Error, [System.Management.Automation.Runspaces.PipelineResultTypes]::Output);
    }else{
      $ps.Commands.Commands[0].MergeMyResults([System.Management.Automation.Runspaces.PipelineResultTypes]::All, [System.Management.Automation.Runspaces.PipelineResultTypes]::Output);
    }
    $asyncResult = $ps.BeginInvoke()

    if (!$asyncResult.AsyncWaitHandle.WaitOne($TimeoutMilliseconds)){
      throw "Catastrophic failure: PowerShell module timeout ($TimeoutMilliseconds ms) exceeded while executing"
    }

    try
    {
      $ps.EndInvoke($asyncResult)
    } catch [System.Management.Automation.IncompleteParseException] {
      # https://msdn.microsoft.com/en-us/library/system.management.automation.incompleteparseexception%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
      throw $_.Exception.Message
    } catch {
      if ($_.Exception.InnerException -ne $null)
      {
        throw $_.Exception.InnerException
      } else {
        throw $_.Exception
      }
    }

    [Puppet.PuppetPSHostUserInterface]$ui = $global:puppetPSHost.UI
    return @{
      exitcode = $global:puppetPSHost.Exitcode;
      stdout = $ui.Output;
      stderr = $ui.StdErr;
      errormessage = $null;
    }
  }
  catch
  {
    try
    {
      if ($global:runspace) { $global:runspace.Dispose() }
    }
    finally
    {
      $global:runspace = $null
    }
    if(($global:puppetPSHost -ne $null) -and $global:puppetPSHost.ExitCode){
      $ec = $global:puppetPSHost.ExitCode
    }else{
      # This is technically not true at this point as we do not
      # know what exitcode we should return as an unexpected exception
      # happened and the user did not set an exitcode. Our best guess
      # is to return 1 so that we ensure Puppet reports this run as an error.
      $ec = 1
    }

    if ($_.Exception.ErrorRecord.InvocationInfo -ne $null)
    {
      $output = $_.Exception.Message + "`n`r" + $_.Exception.ErrorRecord.InvocationInfo.PositionMessage
    } else {
      $output = $_.Exception.Message | Out-String
    }

    # make an attempt to read StdErr as it may contain info about failures
    try { $err = $global:puppetPSHost.UI.StdErr } catch { $err = $null }
    return @{
      exitcode = $ec;
      stdout = $null;
      stderr = $err;
      errormessage = $output;
    }
  }
  finally
  {
    if ($ps -ne $null) { [Void]$ps.Dispose() }
  }
}

function Write-SystemDebugMessage
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [String]
    $Message
  )

  if ($script:EmitDebugOutput -or ($DebugPreference -ne 'SilentlyContinue'))
  {
    [System.Diagnostics.Debug]::WriteLine($Message)
  }
}

function Signal-Event
{
  [CmdletBinding()]
  param(
    [String]
    $EventName
  )

  $event = [System.Threading.EventWaitHandle]::OpenExisting($EventName)

  [Void]$event.Set()
  [Void]$event.Close()
  if ($PSVersionTable.CLRVersion.Major -ge 3) {
    [Void]$event.Dispose()
  }

  Write-SystemDebugMessage -Message "Signaled event $EventName"
}

function ConvertTo-LittleEndianBytes
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [Int32]
    $Value
  )

  $bytes = [BitConverter]::GetBytes($Value)
  if (![BitConverter]::IsLittleEndian) { [Array]::Reverse($bytes) }

  return $bytes
}

function ConvertTo-ByteArray
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [Hashtable]
    $Hash,

    [Parameter(Mandatory = $true)]
    [System.Text.Encoding]
    $Encoding
  )

  # Initialize empty byte array that can be appended to
  $result = [Byte[]]@()
  # and add length / name / length / value from Hashtable
  $Hash.GetEnumerator() |
    % {
      $name = $Encoding.GetBytes($_.Name)
      $result += (ConvertTo-LittleEndianBytes $name.Length) + $name

      $value = @()
      if ($_.Value -ne $null) { $value = $Encoding.GetBytes($_.Value.ToString()) }
      $result += (ConvertTo-LittleEndianBytes $value.Length) + $value
    }

  return $result
}

function Write-StreamResponse
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [System.IO.Pipes.PipeStream]
    $Stream,

    [Parameter(Mandatory = $true)]
    [Byte[]]
    $Bytes
  )

  $length = ConvertTo-LittleEndianBytes -Value $Bytes.Length
  $Stream.Write($length, 0, 4)
  $Stream.Flush()

  Write-SystemDebugMessage -Message "Wrote Int32 $($bytes.Length) as Byte[] $length to Stream"

  $Stream.Write($bytes, 0, $bytes.Length)
  $Stream.Flush()

  Write-SystemDebugMessage -Message "Wrote $($bytes.Length) bytes of data to Stream"
}

function Read-Int32FromStream
{
  [CmdletBinding()]
  param (
   [Parameter(Mandatory = $true)]
   [System.IO.Pipes.PipeStream]
   $Stream
  )

  $length = New-Object Byte[] 4
  # Read blocks until all 4 bytes available
  $Stream.Read($length, 0, 4) | Out-Null
  # value is sent in Little Endian, but if the CPU is not, in-place reverse the array
  if (![BitConverter]::IsLittleEndian) { [Array]::Reverse($length) }
  $value = [BitConverter]::ToInt32($length, 0)

  Write-SystemDebugMessage -Message "Read Byte[] $length from stream as Int32 $value"

  return $value
}

# Message format is:
# 1 byte - command identifier
#     0 - Exit
#     1 - Execute
#    -1 - Exit - automatically returned when ReadByte encounters a closed pipe
# [optional] 4 bytes - Little Endian encoded 32-bit code block length for execute
#                      Intel CPUs are little endian, hence the .NET Framework typically is
# [optional] variable length - code block
function ConvertTo-PipeCommand
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [System.IO.Pipes.PipeStream]
    $Stream,

    [Parameter(Mandatory = $true)]
    [System.Text.Encoding]
    $Encoding,

    [Parameter(Mandatory = $false)]
    [Int32]
    $BufferChunkSize = 4096
  )

  # command identifier is a single value - ReadByte blocks until byte is ready / pipe closes
  $command = $Stream.ReadByte()

  Write-SystemDebugMessage -Message "Command id $command read from pipe"

  switch ($command)
  {
    # Exit
    # ReadByte returns a -1 when the pipe is closed on the other end
    { @(0, -1) -contains $_ } { return @{ Command = 'Exit' }}

    # Execute
    1 { $parsed = @{ Command = 'Execute' } }

    default { throw "Catastrophic failure: Unexpected Command $command received" }
  }

  # read size of incoming byte buffer
  $parsed.Length = Read-Int32FromStream -Stream $Stream
  Write-SystemDebugMessage -Message "Expecting $($parsed.Length) raw bytes of $($Encoding.EncodingName) characters"

  # Read blocks until all bytes are read or EOF / broken pipe hit - tested with 5MB and worked fine
  $parsed.RawData = New-Object Byte[] $parsed.Length
  $read = $Stream.Read($parsed.RawData, 0, $parsed.Length)
  if ($read -lt $parsed.Length)
  {
    throw "Catastrophic failure: Expected $($parsed.Length) raw bytes, only received $read"
  }

  # turn the raw bytes into the expected encoded string!
  $parsed.Code = $Encoding.GetString($parsed.RawData)

  return $parsed
}

function Start-PipeServer
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [String]
    $CommandChannelPipeName,

    [Parameter(Mandatory = $true)]
    [System.Text.Encoding]
    $Encoding
  )

  # this does not require versioning in the payload as client / server are tightly coupled
  $server = New-Object System.IO.Pipes.NamedPipeServerStream($CommandChannelPipeName,
    [System.IO.Pipes.PipeDirection]::InOut)

  try
  {
    # block until Ruby process connects
    $server.WaitForConnection()

    Write-SystemDebugMessage -Message "Incoming Connection to $CommandChannelPipeName Received - Expecting Strings as $($Encoding.EncodingName)"

    # Infinite Loop to process commands until EXIT received
    $running = $true
    while ($running)
    {
      # throws if an unxpected command id is read from pipe
      $response = ConvertTo-PipeCommand -Stream $server -Encoding $Encoding

      Write-SystemDebugMessage -Message "Received $($response.Command) command from client"

      switch ($response.Command)
      {
        'Execute' {
          Write-SystemDebugMessage -Message "[Execute] Invoking user code:`n`n $($response.Code)"

          # assuming that the Ruby code always calls Invoked-PowerShellUserCode,
          # result should already be returned as a hash
          $result = Invoke-Expression $response.Code

          $bytes = ConvertTo-ByteArray -Hash $result -Encoding $Encoding

          Write-StreamResponse -Stream $server -Bytes $bytes
        }
        'Exit' { $running = $false }
      }
    }
  }
  catch [Exception]
  {
    Write-SystemDebugMessage -Message "PowerShell Pipe Server Failed!`n`n$_"
    throw
  }
  finally
  {
    if ($server -ne $null) { $server.Dispose() }
  }
}

Start-PipeServer -CommandChannelPipeName $NamedPipeName -Encoding $Encoding
