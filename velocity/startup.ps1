#!/usr/bin/env pwsh

function Get-OnlineUuid {
    param(
        $Name
    )
    $Uuid = Invoke-RestMethod -Uri "https://minecraft-api.com/api/uuid/$Name"
    $Uuid = "$($Uuid.substring(0,8))-$($Uuid.substring(8,4))-$($Uuid.substring(12,4))-$($Uuid.substring(16,4))-$($Uuid.substring(20))"
    $Uuid
}

if($env:OP) {
    $LuckyUsersPath = '/velocity/plugins/luckperms/json-storage/users/'
    $EnvOps = $env:OP.split(",")

    $EnvOps | ForEach-Object {
        $OpName = $_
        $Uuid = Get-OnlineUuid $OpName
        $OpPath = Join-Path $LuckyUsersPath "$Uuid.json"
        if(!(Test-Path $OpPath)) {
            Write-Host "Adding $OpName perms"
            Set-Content $OpPath -Value (ConvertTo-Json -Depth 10 @{
                uuid = $Uuid
                name = $OpName
                primaryGroup = "default"
                parents = @(
                    @{
                        group = "admin"
                    },
                    @{
                        group = "default"
                    }
                )
            })
        }
    }
}

if(Test-Path /etc/mcinfo -PathType Leaf) {
    Write-Host "Found /etc/mcinfo"
    $mcinfo = Get-Content /etc/mcinfo | ConvertFrom-Json
    $ServerList = @()

    if($mcinfo.proxiedServers) {
        $mcinfo.proxiedServers | ForEach-Object {
            $ServerList += " $($_.Name) = '$($_.dns):25565'"
        }
    }
    for($i = 1; $i -le $mcinfo.lobbyCount; $i++) {
        $ServerList += " lobby = 'manhunt-lobby-${i}:25565'"
    }
    for($i = 1; $i -le $mcinfo.manhuntCount; $i++) {
        $ServerList += " manhunt$i = 'manhunt-manhunt-${i}:25565'"
    }
} else {
    Write-Host "Missing /etc/mcinfo, using default config"
    $ServerList = @(
        " lobby = 'lobby:25565'",
        " manhunt1 = 'manhunt1:25565'"
    )
}

Write-Host "Servers $ServerList"

$velocityConfig = [io.file]::ReadAllText("/velocity/velocity.toml")
$velocityConfig = $velocityConfig.replace("##SERVERS##", @"
$($ServerList -join "`r`n")
"@)
[IO.File]::WriteAllText("/velocity/velocity.toml", $velocityConfig)

java "-Xms$env:Xms" "-Xmx$env:Xmx" -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15 -jar velocity.jar