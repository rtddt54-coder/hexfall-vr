# Hexfall (VR)

Original curse-hunter combat prototype for Quest, built in Godot 4.6.3 with OpenXR.
No characters, names, or franchise-specific content — original mechanics inspired
by the "energy technique" combat genre in general.

## What's here

- `scripts/player.gd` — XR rig: thumbstick locomotion, trigger-bound ability
  casting (left/right hand), essence pool, health, shield, buffs.
- `scripts/wraith.gd` — simple chase/melee enemy AI.
- `scripts/wave_spawner.gd` — spawns waves of Wraiths from marker points.
- `scripts/abilities/` — the ability system:
  - `ability_base.gd` — base `Ability` resource (cost, cooldown, execute()).
  - `energy_bolt.gd` — ranged projectile.
  - `barrier_ward.gd` — timed damage-absorb shield.
  - `reversal_heal.gd` — heal-over-time.
  - `sanctum_break.gd` — ultimate: opens a bounded "Sanctum" zone that
    damages enemies inside it over time and buffs the caster. This is an
    original take on a "bounded arena" ultimate, not a copy of any
    franchise's named technique.
- `resources/*.tres` — pre-configured ability instances, already wired
  into `Player.tscn` (right trigger = Energy Bolt, left trigger = Barrier
  Ward, right A/X button = Sanctum Break).
- `scenes/Main.tscn` — arena floor, 4 spawn points, wave spawner, player
  spawn.

## Controls (default binding)

- Left thumbstick: move
- Left trigger: Barrier Ward
- Right trigger: Energy Bolt
- Right A/X button: Sanctum Break (ultimate)

## Next steps you'll likely want

1. Open in Godot 4.6.x with the OpenXR plugin enabled (Project Settings →
   XR → OpenXR → Enabled, already set in `project.godot`).
2. Swap the primitive capsule/sphere meshes for real models/animations.
3. Add a HUD (health/essence bars) — currently only signals are wired
   (`health_changed`, `essence_changed`), no visual UI yet.
4. Add hand-tracking gesture triggers if you want gesture-based casting
   instead of/alongside controller buttons.
5. Tune numbers in the `.tres` files (cost/cooldown/damage) to taste.

## Export

Same export path as Dead Camp — Android/Quest export template, add the
`XR_HAND_TRACKING` / `com.oculus.permission.HAND_TRACKING` manifest
entries only if you add hand tracking.
