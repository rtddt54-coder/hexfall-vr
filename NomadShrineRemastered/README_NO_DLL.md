# Nomad Shrine Remastered — no-DLL package

This package is derived from the supplied `NomadShrineRemastered` source.

## Included

- Original Unity asset bundles
- Built-in ThunderRoad item definitions
- Version-neutral ability focus items for Reversal Red, Reversal Blue,
  Reversal Purple, and Domain Expansion: Infinite Void
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

## Compatibility

The added ability files use only the common `ThunderRoad.ItemData` type and
minimal fields (`$type`, `id`, `version`, display text, prefab address, and
storage/grip settings). This is the safest JSON shape for older and newer
Nomad releases. It avoids version-specific custom classes and should load
across the supported versions that expose the supplied `gojis.MalovalentShrine`
prefab in the included asset bundle.

JSON alone cannot create new damage, healing, slow, domain, or AI behavior.
The four ability files are portable inventory/focus items; the full gameplay
logic remains in the Godot Hexfall build. Adding that behavior to Nomad would
require a Nomad-supported scripted mod or SDK-built asset, which would no
longer be a no-DLL package.

## Install

Keep the folder name exactly `NomadShrineRemastered` and copy it into the Blade & Sorcery:
Nomad mods directory. This package is intended for the standalone Nomad
runtime and does not include managed code.

The folder name is intentional: the supplied Addressables catalog contains
bundle paths under `NomadShrineRemastered/`. Renaming the folder causes asset
lookup failures or catalog-version/path errors.