function Get-OnlineUuid {
    param(
        $Name
    )
    $Uuid = Invoke-RestMethod -Uri "https://minecraft-api.com/api/uuid/$Name"
    $Uuid = "$($Uuid.substring(0,8))-$($Uuid.substring(8,4))-$($Uuid.substring(12,4))-$($Uuid.substring(16,4))-$($Uuid.substring(20))"
    $Uuid
}

if($env:OP) {
    $LuckyUsersPath = '/paper/plugins/LuckPerms/json-storage/users/'
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
}

if($mcinfo.worldFiles) {
    $worldIndex = 0;
    pushd /server/
    $mcinfo.worldFiles | ForEach-Object {
        wget $_ -O world$worldIndex.tar.gz
        tar xvf world$WorldIndex.tar.gz
    }
    popd
}

$paperyml = [io.file]::ReadAllText("/server/paper.yml")
if($mcinfo.secret) {
    $paperyml = $paperyml -replace '    secret: .*',"    secret: $($mcinfo.secret)"
}
[IO.File]::WriteAllText("/server/paper.yml", $paperyml)