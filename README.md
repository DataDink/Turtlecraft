# TurtleCraft
*A collection of scripts to extend usability of computers and turtles in modded minecraft settings*

### To Install:

> `wget https://raw.githubusercontent.com/DataDink/Turtlecraft/refs/heads/master/update.lua update.lua`

*Executing the update.lua script will download the rest of the files*

## update.lua

Redownloads all of the files to your computer/turtle

## recover.lua

Configures the computer/turtle to execute a command when it boots.

Example: 
> recover ls ./rom/programs

*Lists all of the programs in ./rom/programs whenever the computer/turtle boots*

## drop.lua

"Because solengolia's don't stop everything..."

Some machines in modded minecraft function by consuming dropped items,
but there are all sorts of things that cause dropped items to be moved or deleted.
This will cause a turtle to drop items and then pick them back up after a short time.
The turtle can then be encased or placed in such a way that the items are blocked from being moved.
The items are picked up and re-dropped to help bypass any despawning timers that might delete the items over time.

Example:
> drop

*Drops up to a default of 64 items and lets them sit for 10 seconds*

Example:
> drop 5 30

*Drops up to 5 items and lets them sit for 30 seconds*
