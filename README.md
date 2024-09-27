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

## turtle.recovery.api

When loaded using `os.loadAPI`, adds a recovery API to the turtle API at `turtle.recovery`.
With the addition of a couple of extra steps each time you move the turtle,
this API will assist in recovering from chunk unloads & unexpected reboots.
It can only recover certain commands with variable reliability:

<table>
  <tr><th><code>forward</code></th><td>100%</td></tr>
  <tr><th><code>back</code></th><td>100%</td></tr>
  <tr><th><code>up</code></th><td>100%</td></tr>
  <tr><th><code>down</code></th><td>100%</td></tr>
  <tr><th><code>turnLeft</code></th><td>&lt; 100%</td></tr>
  <tr><th><code>turnRight</code></th><td>&lt; 100%</td></tr>
</table>

Example:
```lua
os.loadAPI('turtle.recovery.api')

-- Check for recovery when the program starts...
local reliability = turtle.recovery.getReliability()
if (reliability == 1) then
  print('Recovering last turtle movement...')
  turtle.recovery.execute()
elseif (reliability > 0) then
  print('Attempting recovery of last turtle movement. Steps should be taken to assure expected positioning & facing')
  turtle.recovery.execute()
else
  print('There was nothing recoverable...')
end

-- Protect a forward movement
turtle.recovery.set('forward')
-- Execute the protected movement
turtle.recovery.execute()
```

If a program interruption happens between a `set` and `execute`, the command will be re-`set` the next time the API is loaded.
