

"16.5","17","17.1" | ForEach-Object {
    docker build -t paper:$_ -f ./base/Dockerfile.$_ ./base
}

"blockhunt", "clipso-mega-modded", "manhunt", "minigames" | ForEach-Object {
    docker build -t $_ ./$_
}