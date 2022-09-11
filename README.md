<p align="center">
  <img src="https://user-images.githubusercontent.com/270076/120495363-036cc180-c393-11eb-89b7-19d7d84e0af8.png" width="401" height="351" alt="World of Warcraft®">
  <br />
  My add-ons for World of Warcraft®.
</p>

---

## Retail

Add-ons compatible with WoW Retail (9.x).

- [**Fastbind**](/retail/Fastbind)
- [**Tunnelvision**](/retail/Tunnelvision)

## WotLK Classic

Add-ons compatible with WoW WotLK Classic (3.4.x).

- [**Threatrack**](/classic/Threatrack)
- [**Fastbind**](/classic/Fastbind)
- [**Tunnelvision**](/classic/Tunnelvision)

## Development

To install all add-ons via symbolic link, use the script `Install.ps1`. Launch a PowerShell prompt and execute the snippet below, changing the game installation path accordingly.

```
> Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
> .\Install.psq -Game "C:\World of Warcraft"
```

Please note;

1. The tooling is designed to work in Linux, like WSL, not Windows.
2. This repository tracks several add-ons for different versions of WoW.
3. Never commit changes to multiple add-ons at the same time.
4. Commits **should** link to one or more existing issues, e.g. `Bump interface compatibility #11`.
5. Tags **must** follow the format `platform/name/version`, e.g. `classic/Tunnelvision/1.0.0`.

### Linting

Both Lua and XML files must pass through validation.

```sh
$ scripts/lint <directory>
```

The script will recursively walk the given directory looking for files to validate, report and exit with a non-zero status if issues are encountered.

### Releases

Do **not** ever edit versions manually! Use the script:

```sh
$ scripts/release [-h|-p|-m|-M] <path>
```

This will bump the version string of given add-on, commit it, tag it and push to the remote respository, which will trigger a new automated release. Options `-p`, `-m`, or `-M` stand for patch, minor, or major release respectively. Patch version counts the commits since last release. Minor and major versions are increments of one on top of the current version.

## Legal

The MIT License © 2017 Arthur Corenzan

These Add-ons are not created by, affiliated with or sponsored by Blizzard Entertainment, Inc. or its affiliates. The World of Warcraft® and related logos are registered trademarks or trademarks of Blizzard Entertainment, Inc. in the United States and/or other countries. All rights reserved.
