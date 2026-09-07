# Nomad Shrine JSON-only build

This is the compatibility build for installs that report a wrong catalog
version.

## Why this build avoids the error

The supplied source contains one Unity Addressables catalog and two Android
asset bundles. That catalog is tied to the Unity/game build that produced it;
it is not made backwards-compatible by changing JSON `version` fields. No
older catalog was present in the supplied source.

This package intentionally contains:

- No `catalog_*.json`
- No `.bundle` files
- No `.dll` or `.pdb` files
- Only built-in `ThunderRoad.ItemData` JSON definitions
- The exact game version reported by the supplied player log: `1.0.7.677`
- The built-in `Bas.Item.Misc.SkillOrb` prefab, which is referenced by the
  supplied Shrine spell data

## Install

Copy the `NomadShrineJSONOnly` folder into:

`Android/data/com.Warpfrog.BladeAndSorcery/files/Mods/`

Remove older `NomadShrineRemastered` copies first. Do not place both packages
in the Mods folder while testing, because duplicate IDs can make the catalog
refresh fail.

This is a data-only compatibility package. JSON can register the portable
focus items, but it cannot implement custom damage, healing, slowing, domain,
or AI logic without a scripted mod or SDK-built asset.