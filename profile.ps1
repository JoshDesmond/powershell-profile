# Logging Function
function Print-ProfileLog {
	param($text)
	Write-Host $text -ForegroundColor green	
}

#======================
#=== Machine Logic ====
#======================
$isWindows = ($env:OS -like "*windows*")
$isVirtusa = ($env:COMPUTERNAME -eq "WTLJDESMOND")
$isDesktop = ($env:COMPUTERNAME -eq "DESKTOP-TOBINO0")
$isLaptop = ($env:COMPUTERNAME -eq "Desktop-G1SKU")
$isPersonal = ($isDesktop -or $isLaptop)

#======================
#====== Aliases =======
#======================
Print-ProfileLog 'Configuring Aliases'
New-Alias ppl Print-ProfileLog -Force
New-Alias which get-command -Force
New-Alias npp OpenWith-NotepadPlusPlus -Force
New-Alias version Get-PowershellVersion -Force
New-Alias vim nvim -Force
New-Alias vi vim -Force
New-Alias sha Get-StringHash -Force
if ($isPersonal) {
	New-Alias pc "C:\Users\$env:username\Google Drive\Percent Complete 2017.xlsx" -Force
}

#======================
#=== $Env Settings ====
#======================
ppl 'Configuring Env Settings'

# Colors:
$colors = $host.privatedata
$colors.ErrorBackgroundColor = "DarkGray"
$colors.WarningBackgroundColor = "DarkGray"
$colors.DebugBackgroundColor = "DarkGray"
$colors.VerboseBackgroundColor = "DarkGray"

# Console Config:
$console = $host.ui.rawui
$console.backgroundcolor = "black"
$MaximumHistoryCount = 32767

# $Env:
$Env:Path += ";C:\Shortcuts"
if ($isDesktop) {
	# TODO set up laptop to have same structure
	$Env:PSModulePath += ";C:\code\powershell-modules"
}
if ($isVirtusa) {
	$Env:Path += ";C:\Users\jdesmond\Documents\Neovim\bin\"
}

#======================
#== Import Chocolatey =
#======================
ppl 'Importing Chocolatey'
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

#======================
#=== Import Modules ===
#======================
ppl 'Importing Posh-Git'
if ($isDesktop) {
Import-Module 'C:\tools\poshgit\dahlbyk-posh-git-9bda399\src\posh-git.psd1'
} else {
	Import-Module posh-git
}

ppl 'Importing Posh-Sshell'
Import-Module posh-ssh

#ppl 'Importing AWSPowerShell'
#Import-Module AWSPowerShell

#======================
#===== Functions ====== 
#======================
ppl 'Defining Functions'

# Print-NodePackages
# Prints the current npm packages installed in the local directory
function Print-NodePackages {
	npm list --depth 0
}

# ll
# Colorized LS function replacement. See:
# http://mow001.blogspot.com 
# http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file
function ll {
	param ($dir = ".", $all = $false) 

	$origFg = $host.ui.rawui.foregroundColor 

	if ( $all ) { $toList = ls -force $dir }
	else { $toList = ls $dir }

	foreach ($Item in $toList) { 
		Switch ($Item.Extension) { 
			".Exe" {$host.ui.rawui.foregroundColor = "Yellow"} 
			".cmd" {$host.ui.rawui.foregroundColor = "Red"} 
			".msh" {$host.ui.rawui.foregroundColor = "Red"} 
			".vbs" {$host.ui.rawui.foregroundColor = "Red"} 
			Default {$host.ui.rawui.foregroundColor = $origFg}
		} 
		if ($item.Mode.StartsWith("d")) {$host.ui.rawui.foregroundColor = "Green"}
		$item
	}  
	$host.ui.rawui.foregroundColor = $origFg 
}

function lla {
	param ( $dir=".")
	ll $dir $true
}

function la {ls -force}

# Print-Colors
# Prints a line of each color to console.
function Print-Colors {
	[System.ConsoleColor].GetEnumValues() | ForEach-Object { Write-Host $_ -ForegroundColor $_ }
}

# Get-StringHash
# Prints the Sha1 hash of a string
# http://jongurgul.com/blog/get-stringhash-get-filehash/ 
Function Get-StringHash([String] $String, $HashName = "SHA1") {
	$StringBuilder = New-Object System.Text.StringBuilder 
	[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{
		[Void]$StringBuilder.Append($_.ToString("x2")) 
	}
	$StringBuilder.ToString() 
}

# Block-YouTube
# Adds YouTube.com to the hosts file.
Function Block-Youtube {
	if (-Not $isWindows) { return }

	$hosts = 'C:\Windows\System32\drivers\etc\hosts'

	$is_blocked = Get-Content -Path $hosts |
	Select-String -Pattern ([regex]::Escape("youtube.com"))

	If(-not $is_blocked) {
		Add-Content -Path $hosts -Value "127.0.0.1 youtube.com"
			Add-Content -Path $hosts -Value "127.0.0.1 www.youtube.com"
	}
}

# Unblock-YouTube
# Removes any lines from the hosts file containing Youtube.com
Function Unblock-Youtube {
	if (-not $isWindows) { return }

	$hosts = 'C:\Windows\System32\drivers\etc\hosts'

	$is_blocked = Get-Content -Path $hosts |
	Select-String -Pattern ([regex]::Escape("youtube.com"))

	If($is_blocked) {
		$newhosts = Get-Content -Path $hosts |
			Where-Object {
				$_ -notmatch ([regex]::Escape("youtube.com"))
			}
		Set-Content -Path $hosts -Value $newhosts
	}
}

# OpenWith-NotepadPlusPlus
# Opens a file with notepad++
Function OpenWith-NotepadPlusPlus {
	notepad++.lnk (Get-ChildItem $args[0])
}

# Get-History-All
# Outputs the entire history that's saved
Function Get-History-All {
	cat (Get-PSReadlineOption).HistorySavePath
}

# Start-StartTranscript
# Starts a transcription of the current powershell session at the path ${tracefile}
Function Start-StartTranscript {
	if (-not $isWindows) { break }
	$tracefile="C:\Users\$env:username\Documents\WindowsPowerShell\Logs\PS-Session-$(get-date -format 'yyyyMMdd-HHmm').txt"
	Start-Transcript -Path $tracefile -NoClobber
}

# git-whoami
# Prints to console the configured username and email in the current directory
Function git-whoami {
	$gitUserName = git config user.name
	$gitUserEmail = git config user.email
	Write-Host "Name: ${gitUserName}, Email: ${gitUserEmail}"
}

# Confirm-UserApproval
# Prompts the user with ${PromptText} text, and exits 
Function Confirm-UserApproval([String] $PromptText="Are you sure you would like to proceed") {
	$confirmation = Read-Host $PromptText
	if ($confirmation -eq 'y') {
		# proceed
		return True
		}
	else {
		return false
	}
}

# Measure-LastCommand
# Outputs the amount of time it took for the last command in shell history to run
Function Measure-LastCommand() {
	$command = Get-History -Count 1
	($command.EndExecutionTime - $command.StartExecutionTime) | Format-Table
}

# Returns the version of powershell that is running.
Function Get-PowershellVersion { $PSVersionTable }

#======================
#=Me Specific Commands=
#======================
ppl 'Defining Personal Functions'

# Starts the IOTA Full Node running on localhost:14625
if ($isDesktop) {
Function Launch-IOTA {
	java -jar C:\Git\iri\target\iri-1.4.1.4.jar -p 14265
}
}

# This doesn't work.
if ($isVirtusa) {
Function Launch-VM {
	$vbox_file = Get-Item "C:\Users\$env:username\VirtualBox VMs\CentOS 7\CentOS 7.vbox"
	start-job {C:\Program Files\Oracle\VirtualBox\VBoxHeadless.exe -startvm $vbox_path -v}
	Write-Host "If ssh fails, try the following command again more than once"
	Write-Host "ssh -p2222 admin@127.0.0.1 -v" -ForegroundColor green
	Write-Host "You can access the PowerShell jobs with the variable $job"
	ssh -p2222 admin@127.0.0.1 -v
}
}

if ($isVirtusa) {
Function CentOSSH {
	ssh -p2222 admin@127.0.0.1 -v
}
}

# Adding an external script real quick.
if ($isVirtusa) {
	get-content -path C:\Shortcuts\lunatic.ps1 -raw | invoke-expression
}

if ($isVirtusa) {
Function chrome-debug ($cport = 9222) {
	$chrome ="$((Get-ChildItem "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe").Directory)\Chrome.exe"
	$ccommand = "& '$chrome' --remote-debugging-port=$cport"
	Write-Host "Invoking $ccommand"
	Invoke-Expression "& '$chrome' --remote-debugging-port=$cport"
}
}
#======================
#==== Finishing Up ====
#======================
# Clear-Host
Write-Host 'Configuration Complete. Hello!'

# Notes and Favorited Commands:
# dir *.cs -Recurse | sls "TODO" | select -Unique "Path" #grep
# Get-Command -Module PackageManagement # Prints available commands in the PackageManagement module
# Get-Package -Provider Programs -IncludeWindowsInstaller # Shows everything installed
# Get-Content -path C:\CS\Powershell\script.ps1 -raw | invoke-expression # can add an external script
# $tracefile="$pwd\$(get-date -format 'MMddyyyy').txt" # Neat way to concat strings
# eval $(ssh-agent -s) , ssh-add ~/.ssh/id_rsa
# Get-Process | Sort CPU -Desc | Select -First 5
# Measure-Command { npm test | Out-Default } | Out-Default is better than Out-Host if you're scripting
# Get-History | Group {$_.StartExecutionTime.Hour} | sort Count -desc
# Get-PSDrive # outputs drives you can jump to
# Get-NetTCPConnection | ? State -eq Established | ? RemoteAddress -notlike 127* | % { $_; Resolve-DnsName $_.RemoteAddress -type PTR -ErrorAction SilentlyContinue }
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-6

# Instead Of           Use
# ----------           ---
# $env:USERNAME        [Environment]::UserName
# $env:COMPUTERNAME    [Environment]::MachineName
# `n                   [Environment]::NewLine
# `r`n                 [Environment]::NewLine
# $env:TEMP            [IO.Path]::GetTempDirectory()
