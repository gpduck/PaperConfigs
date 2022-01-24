execute if score powercore powercore.tick matches 25.. run scoreboard players set powercore powercore.tick 0

scoreboard players add powercore powercore.tick 1

execute if score powercore powercore.tick matches 1 as @e[type=marker,tag=one] at @s run fill ~ ~ ~ ~ ~ ~ minecraft:redstone_block replace
execute if score powercore powercore.tick matches 9 as @e[type=marker,tag=two] at @s run fill ~ ~ ~ ~ ~ ~ minecraft:redstone_block replace
execute if score powercore powercore.tick matches 17 as @e[type=marker,tag=three] at @s run fill ~ ~ ~ ~ ~ ~ minecraft:redstone_block replace

execute if score powercore powercore.tick matches 1 as @e[type=marker,tag=!one] at @s run fill ~ ~ ~ ~ ~ ~ minecraft:air replace
execute if score powercore powercore.tick matches 9 as @e[type=marker,tag=!two] at @s run fill ~ ~ ~ ~ ~ ~ minecraft:air replace
execute if score powercore powercore.tick matches 17 as @e[type=marker,tag=!three] at @s run fill ~ ~ ~ ~ ~ ~ minecraft:air replace