Write-Host 'Hello!'

New-Alias npp notepad++.lnk
New-Alias pc "C:\Users\$env:username\Google Drive\Percent Complete 2017.xlsx"
 
# Colorized LS function replacement 
# http://mow001.blogspot.com 
# http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file
# Does not work on ubuntu bash
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


# Prints a line of each color to console.
Function Print-Colors {
	[System.ConsoleColor].GetEnumValues() | ForEach-Object { Write-Host $_ -ForegroundColor $_ }
}

# Prints the Sha1 hash of a string
# http://jongurgul.com/blog/get-stringhash-get-filehash/ 
Function Get-StringHash([String] $String, $HashName = "SHA1") 
{ 
	$StringBuilder = New-Object System.Text.StringBuilder 
	[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{ 
	[Void]$StringBuilder.Append($_.ToString("x2")) 
} 
$StringBuilder.ToString() 
}

# Adds YouTube.com to the hosts file.
Function Block-Youtube {
    $hosts = 'C:\Windows\System32\drivers\etc\hosts'

    $is_blocked = Get-Content -Path $hosts |
    Select-String -Pattern ([regex]::Escape("youtube.com"))

    If(-not $is_blocked) {
       Add-Content -Path $hosts -Value "127.0.0.1 youtube.com"
	   Add-Content -Path $hosts -Value "127.0.0.1 www.youtube.com"
    }
}

# Removes any lines from the hosts file containing Youtube.com
Function Unblock-Youtube {
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

# Sets the background color of the prompt to the default powershell blue
Function Set-Colors {

}
#======================
#=Me Specific Commands=
#======================

# Starts the IOTA Full Node running on localhost:14625
Function Launch-IOTA {
	java -jar C:\Git\iri\target\iri-1.4.1.4.jar -p 14265
}
