# Hexfall (VR)

Original curse-hunter combat prototype for Quest, built in Godot 4.6.3 with OpenXR.
No characters, names, or franchise-specific content — original mechanics inspired
by the "energy technique" combat genre in general.

## What's here

- `scripts/player.gd` — XR rig: thumbstick locomotion with proper gravity,
  snap-turn (right stick), trigger-bound ability casting (left/right hand),
  B/Y button secondary ability, essence pool, health, shield, buffs, score tracking.
- `scripts/wraith.gd` — chase/melee enemy AI with flank-strafe offset,
  hit-stagger, hit-flash feedback, per-wave stat scaling, and score award on death.
- `scripts/wave_spawner.gd` — spawns scaling waves; emits `wave_started`,
  `wave_cleared` signals wired to the HUD via GameManager.
- `scripts/game_manager.gd` — connects player + wave spawner signals to the HUD;
  handles game-over state.
- `scripts/hud.gd` — world-space VR HUD that follows the XRCamera. Draws health,
  essence, shield bars, score, wave counter, and wave-banner announcements using
  a SubViewport + CanvasLayer (no external assets required).
- `scripts/abilities/` — the ability system:
  - `ability_base.gd` — base `Ability` resource (cost, cooldown, execute(),
    `cooldown_fraction()`, `cooldown_remaining()`).
  - `energy_bolt.gd` — ranged projectile with configurable bolt color.
  - `barrier_ward.gd` — timed damage-absorb shield.
  - `reversal_heal.gd` — heal-over-time (now assigned to B/Y button).
  - `sanctum_break.gd` — ultimate: opens a bounded "Sanctum" zone that
    damages enemies inside it over time, buffs the caster, and pulses visually.
  - `projectile_runtime.gd` — dynamic projectile with impact-flash OmniLight.
  - `sanctum_zone_runtime.gd` — pulsing zone with tween-driven fade-out.
- `resources/*.tres` — pre-configured ability instances wired into `Player.tscn`.
- `scenes/Main.tscn` — arena floor (with subtle emissive glow), atmosphere with
  bloom, 4 spawn points, wave spawner, player spawn, GameManager, HUD.
- `scenes/HUD.tscn` — minimal HUD scene instantiated by Main.

## Controls (default binding)

| Input | Action |
|---|---|
| Left thumbstick | Move |
| Right thumbstick left/right | Snap turn (30°) |
| Left trigger | Barrier Ward |
| Right trigger | Energy Bolt |
| Right A/X button | Sanctum Break (ultimate) |
| Left B/Y button | Reversal Heal |

## Build (GitHub Actions)

Pushing to `main` or `master` triggers `.github/workflows/build-apk.yml`:
- Downloads Godot 4.6.3 headless + Android export templates
- Exports `build/hexfall_vr.apk` (debug-signed)
- Uploads as a GitHub Actions artifact (30-day retention)

For a release-signed build, set these repo secrets:
`RELEASE_KEYSTORE_BASE64`, `RELEASE_KEYSTORE_ALIAS`, `RELEASE_KEYSTORE_PASS`,
`RELEASE_KEY_PASS` — then change `--export-debug` to `--export-release`.

## Next steps

1. Open in Godot 4.6.x with OpenXR enabled (already set in `project.godot`).
2. Swap primitive capsule/sphere meshes for real models/animations.
3. Add hand-tracking gesture triggers for gesture-based casting.
4. Tune numbers in the `.tres` files (cost / cooldown / damage) to taste.
5. Add a persistent high-score system (file or server-backed).
