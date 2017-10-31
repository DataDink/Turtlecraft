TurtleCraft 2.0
---------------

**Install**

```
pastebin get <version key> startup
reboot
```

*versions:*

- Debug key: kLMahbgd
- Test key: nTNP03Bw
- Release key: ??? <-- does not exist yet

**About**

This is a mini, menu-driven OS for turtles from the ComputerCraft mod.
The key feature of this system is its recovery service.
When the chunk unloads and reloads the turtle will (usually) pick up where it left off.
The system is not perfect, but as fail-safe as I can make it.

**2.0**

*Notes:*

- Rewrite: The old version was like 10+ years old and unmaintainable.
- Code Breakout: Improved maintainability / extensibility
- Release Pipeline: Now config-based "debug"/"test"/"release" to make this more shareable with friends.
- Self-Updating: You can update to the latest version as a menu item.
- The recovery services I think are a more solid approach
- Removed all the crap, currently only 2 plugins (I do plan on making more)
- Efficient Excavate:
  - Mines 3 planes at a time (+ up and down)
  - Searches for fuel in all slots instead of just 1
  - Auto consolidates inventory

*Plans:*

- Extensions: A plugin that manages loading external plugins from the internetz
- Builder Plugins: Various plugins that will help build shapes 'n things
- Farming Plugins: Plugins that plant, pick, attack, etc

***I FREAKING LOVE COMPUTERCRAFT!***
