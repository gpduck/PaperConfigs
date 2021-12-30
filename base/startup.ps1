#!/usr/bin/env pwsh

function Get-OfflineUuid {
    param(
        $Name
    )
    $String = "OfflinePlayer:$Name"

    $md5 = [System.Security.Cryptography.MD5]::create()
    $Hash = $md5.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))
    $Hash[6] = $Hash[6] -band 0x0f;
    $Hash[6] = $Hash[6] -bor 0x30;
    $Hash[8] = $Hash[8] -band 0x3f;
    $Hash[8] = $Hash[8] -bor 0x80;

    function swap {
    param(
        $array,
        $start,
        $end
    )
    $Temp = $Array[$start]
    $Array[$Start] = $Array[$End]
    $Array[$End] = $Temp
    }

    swap $Hash 0 3
    swap $Hash 1 2
    swap $Hash 4 5
    swap $Hash 6 7

    [guid]::new($Hash).ToString()
}

function Get-OnlineUuid {
    param(
        $Name
    )
    $Uuid = Invoke-RestMethod -Uri "https://minecraft-api.com/api/uuid/$Name"
    $Uuid = "$($Uuid.substring(0,8))-$($Uuid.substring(8,4))-$($Uuid.substring(12,4))-$($Uuid.substring(16,4))-$($Uuid.substring(20))"
    $Uuid
}

function Get-ServerProperties {
    param(
        $Path = "/server/server.properties"
    )
    $Props = @{}
    Get-Content -Path $Path | ForEach-Object {
        $Key,$Value = $_.split("=")
        $Props[$Key] = $Value
    }
    $Props
}

if(!(Test-Path /server/server.properties)) {
    Copy-Item /paper/server.properties /server/
}

if(!(Test-Path /server/spigot.yml) -and (Test-Path /paper/spigot.yml)) {
    Copy-Item /paper/spigot.yml /server/
}

if(!(Test-Path /server/eula.txt)) {
    Set-Content -Path /server/eula.txt -Value "eula=true"
}

$ServerProps = Get-ServerProperties

if($env:OP) {
    $OpsPath = '/server/ops.json'
    $EnvOps = $env:OP.split(",")
    $dirty = $false

    if(Test-Path $OpsPath) {
        $Ops = Get-Content $OpsPath | ConvertFrom-Json -AsHashtable
    } else {
        $Ops = @()
        $dirty = $true
    }

    $EnvOps | ForEach-Object {
        $OpName = $_
        if($OpName -notin $Ops.name) {
            $dirty = $true
            if($ServerProps["online-mode"] -eq "true") {
                $Uuid = Get-OnlineUuid $OpName
            } else {
                $Uuid = Get-OfflineUuid $OpName
            }
            $Ops += @{
                uuid = $Uuid
                name = $OpName
                level = 4
                bypassesPlayerLimit = $true
            }
        }
    }
    if($dirty) {
        Set-Content $OpsPath -Value (ConvertTo-Json $Ops -Depth 10)
    }
}

if(Test-Path /paper/init.ps1) {
    /paper/init.ps1
}

java "-Xms$env:Xms" "-Xmx$env:Xmx" -jar /paper/paper.jar --nogui --server-name $env:SERVER_NAME --plugins /paper/plugins