# Nomad Shrine Remastered — no-DLL package

This package is derived from the supplied `NomadShrineRemastered` source.

## Included

- Original Unity asset bundles
- Built-in ThunderRoad item definitions
- Effects
- Hand poses
- `manifest.json`

## Removed

- `NomadShrineRemastered.dll`
- `NomadShrineRemastered.pdb`
- The three JSON spell definitions whose root types are custom C# classes:
  - `FugaMerge`
  - `MalovalentShrine`
  - `ShrineNormal`

Those spell definitions require the compiled DLL to instantiate their custom
ThunderRoad behaviour. Keeping them in a no-DLL package would make the mod
fail to load or produce catalog errors on standalone Nomad.

## Install

Copy the `NomadShrineRemasteredNoDLL` folder into the Blade & Sorcery:
Nomad mods directory. This package is intended for the standalone Nomad
runtime and does not include managed code.