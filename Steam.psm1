$steamAppsDir = (Get-Item HKCU:\Software\Valve\Steam).GetValue("SteamPath") + "/steamapps/common/"

$gameLocPattern = [regex]"<SYMLINKD>\s*(?<Game>.*)\[(?<Location>.*)\]$"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

function Get-SteamGame
{
    param(
        [Switch]$Moved,
        [Switch]$NotMoved
    )

    $apps = Get-ChildItem $steamAppsDir

    if(-Not $Moved -and -not $NotMoved)
    {
        $Moved = $true
        $NotMoved = $true
    }

    if($Moved)
    {
        $output = cmd /c dir $steamAppsDir /A:L

        $output = @($output | where { ($gameLocPattern.Match($_)).Success })

        for($i = 0; $i -lt $output.Length; $i++)
        {
            $match = $gameLocPattern.Match($output[$i])
            $name = $match.Groups["Game"].Value.Trim()
            $location = $match.Groups["Location"].Value.Trim()

            Get-Item $location
        }
    }
    
    if($NotMoved)
    {
        $apps | where { !($_.Attributes.ToString().Contains("ReparsePoint")) }
    }
}

function Move-SteamGame
{
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [String]$Game, 
        
        [Parameter(Position=1,Mandatory=$true)]
        [String]$Destination
    )

    if($Host.Version.Major -lt 3)
    {
        Write-Error "This script requires PowerShell 3.0+"
        Break
    }

    If (-Not $isAdmin)
    {
        Write-Warning "This script requires Admin."
        Break
    }

    $availableGames = Get-SteamGame -NotMoved
    $gameNames = $availableGames | select { $_.Name }

    if(-Not ($availableGames.Name -contains $Game))
    { 
        Write-Warning "Your requested game `"$Game`" was unavailable. Please use one of the following:"
        $availableGames
        break
    }

    $gameFolder = $availableGames | where { $_.Name -eq $Game }

    $DestinationPath = $Destination + "\" + $gameFolder.Name

    $ErrorActionPreference = "SilentlyContinue"

    $item = Get-Item $DestinationPath -ErrorVariable $getError

    $exists = ($item -ne $null)

    $ErrorActionPreference = "Stop"

    if(-Not $exists)
    {
        Write-Progress -Activity "Moving $Game to $DestinationPath" -Status "Copying. Please be patient." -CurrentOperation "Moving Game"
        Move-Item -Path $gameFolder.FullName -Destination $Destination

        cmd /c mklink /D $gameFolder.FullName $DestinationPath
    }
    else
    {
        Write-Warning "The game already exists at $Destination."
    }
}

function Restore-SteamGame
{
    param(
    [Parameter(Position=0,Mandatory=$true)]
    [String]$Game
    )

    if($Host.Version.Major -lt 3)
    {
        Write-Error "This script requires PowerShell 3.0+"
        Break
    }

    If (-Not $isAdmin)
    {
        Write-Warning "This script requires Admin."
        Break
    }

    $availableGames = Get-SteamGame -Moved

    if(-Not ($availableGames.Name -contains $Game))
    { 
        Write-Warning "Your requested game `"$Game`" was unavailable. Please use one of the following:"
        $availableGames
        break
    }

    $steamGameDir = $steamAppsDir + $Game

    Write-Progress -Activity "Moving $Game to $steamGameDir" -Status "Copying. Please be patient." -CurrentOperation "Moving Game"

    cmd /c rmdir $steamGameDir

    $item = $availableGames | where { $_.Name -eq $Game }
    Move-Item -Path $item.FullName -Destination $steamGameDir
}