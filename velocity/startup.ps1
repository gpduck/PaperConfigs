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

java "-Xms$env:Xms" "-Xmx$env:Xmx" -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15 -jar velocity.jar