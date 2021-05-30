<p align="center"><img src="wow.png" width="600" height="232" alt="World of Wacraft"></p>
<p align="center">My add-ons for World of Warcraft®.</p>

---

## Retail

Add-ons compatible with WoW Retail (9.x).

- [**Fastbind**](/retail/Fastbind)
- [**Focused**](/retail/Focused)

## TBC Classic

Add-ons compatible with WoW TBC Classic (2.5.x).

- [**Threatrack**](/classic/Threatrack)
- [**Fastbind**](/classic/Fastbind)
- [**Focused**](/classic/Focused)

## Development

- The tooling is designed to work in a Unix environment.
- This repository tracks several add-ons for different versions of WoW.
- Always use separate commits for changes in different add-ons.
- Commits **must** link to one or more existing issues, e.g. `Bump interface compatibility (#11)`.
- Tags **must** follow the format `platform/name/version`, e.g. `classic/Focusight/1.0.0`.

## Linting

Both Lua and XML files are validated on CI, but you can do it manually as well:

```shell
scripts/lint <directory>
```

The script will recursively walk the given directory looking for files to validate and exit non-zero status if any issue is encountered.

## Releases

Do **not** edit versions manually! Use the script:

```shell
scripts/release [-h|-p|-m|-M] <path>
```

This will bump the version given given add-on, commit it, tag it and push to the remote respositorym, which will trigger a new release. Options `-p`, `-m`, or `-M` stand for patch, minor, or major release respectively. Patch version counts the commits since last release. Minor and major versions are increments of one and resets the patch version.

## Legal

The MIT License © 2017 Arthur Corenzan

These Add-ons are not created by, affiliated with or sponsored by Blizzard Entertainment, Inc. or its affiliates. The World of Warcraft® and related logos are registered trademarks or trademarks of Blizzard Entertainment, Inc. in the United States and/or other countries. All rights reserved.
