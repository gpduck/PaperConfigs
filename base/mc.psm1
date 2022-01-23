
function Backup-World {
    param(
        $World = "world"
    )
    pushd /server
    $Filename = "${World}_{0}.tar.gz" -f ([DateTime]::now.toString("yyyy-MM-dd_HH-mm-ss"))
    tar -czvf $Filename $World
}

function Get-McInfo {
    if(Test-Path /etc/mcinfo -PathType Leaf) {
        Write-Host "Found /etc/mcinfo"
        return (Get-Content /etc/mcinfo | ConvertFrom-Json)
    }
}

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

function Import-World {
    param(
        [string[]]$Worlds = @()
    )
    if($Worlds) {
        $worldIndex = 0;
        pushd /server/
        $Worlds | ForEach-Object {
            wget $_ -O world$worldIndex.tar.gz
            tar xvf world$worldIndex.tar.gz
        }
        popd
    }
}

function Set-LuckPermsOps {
    param(
        [string[]]$Ops = @()
    )
    $LuckyUsersPath = '/paper/plugins/LuckPerms/json-storage/users/'
    if(!(Test-Path $LuckyUsersPath)) {
        New-Item -Path $LuckyUsersPath -Force -ItemType Directory > $null
    }

    $Ops | ForEach-Object {
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