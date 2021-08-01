#!/usr/bin/env pwsh

if(!(Test-Path /server/eula.txt)) {
    Set-Content -Path /server/eula.txt -Value "eula=true"
}

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
            $Uuid = Invoke-RestMethod -Uri "https://minecraft-api.com/api/uuid/$OpName"
            $Uuid = "$($Uuid.substring(0,8))-$($Uuid.substring(8,4))-$($Uuid.substring(12,4))-$($Uuid.substring(16,4))-$($Uuid.substring(20))"
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

if(!(Test-Path /server/server.properties)) {
    Copy-Item /paper/server.properties /server/
}

java -Xms2G -Xmx2G -jar /paper/paper.jar --nogui --server-name $env:SERVER_NAME --plugins /paper/plugins