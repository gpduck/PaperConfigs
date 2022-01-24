Import-Module mc

if($env:OP) {
    Set-LuckPermsOps -Ops ($env:OP.split(",'"))
}

$mcinfo = Get-McInfo

if($mcinfo.worldFiles -and !$env:KEEP_WORLD -eq "true") {
    Import-World
}


if($mcinfo.worldFiles -and !$env:KEEP_WORLD -eq "true") {
    Import-World -Worlds $mcinfo.worldFiles
}

$paperyml = [io.file]::ReadAllText("/server/paper.yml")
if($mcinfo.secret) {
    $paperyml = $paperyml -replace '    secret: .*',"    secret: $($mcinfo.secret)"
}
[IO.File]::WriteAllText("/server/paper.yml", $paperyml)