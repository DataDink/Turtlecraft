# TurtleCraft
*A collection of scripts to extend usability of computers and turtles in modded minecraft settings*

### To Install:

> `wget https://raw.githubusercontent.com/DataDink/Turtlecraft/refs/heads/master/update.lua install.lua`

*Executing the update.lua script will download the rest of the files*

## update.lua

Redownloads all of the files to your computer/turtle

## recover.lua

Configures the computer/turtle to execute a command when it boots.

Example: 
> recover ls ./rom/programs

*Lists all of the programs in ./rom/programs whenever the computer/turtle boots*

## drop.lua

"Because solengolia's can only do so much..."

Some machines in modded minecraft function by consuming dropped items,
but there are all sorts of things that cause dropped items to be moved or deleted.
Drop ejects items and then pick them back up after a short time.
This can help with preventing despawn.

<image style="width: 512px" src="drop.jpg" />

Example:
> drop

*Drops up to a default of 64 items and lets them sit for 10 seconds*

Example:
> drop 5 30

*Drops up to 5 items and lets them sit for 30 seconds*

## farm.lua

Farms the spaces around the turtle, harvesting and replanting mature crops and ejecting the yield above or below.

<image style="width: 512px" src="farm.jpg" />

Example:
> farm

*Rotates every 10 seconds looking for a mature crop and ejects upward*

Example:
> farm 30 down

*Rotates every 30 seconds looking for a mature crop and ejects downward*
