param(
    $Image = "*"
)

"16.5","17","17.1","18.1",<#"forge17.1","forge18.1",#>"velocity" | ForEach-Object {
    docker build -t paper:$_ -f ./base/Dockerfile.$_ ./base
}

"blockhunt", "clipso-mega-modded", "lobby", "manhunt", "manhunt-twitchspawn", "minigames", "terminator" | ?{$_ -like $Image} | ForEach-Object {
    docker build -t $_ ./$_
}