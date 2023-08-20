<p align="center">
  <img src="https://user-images.githubusercontent.com/270076/120495363-036cc180-c393-11eb-89b7-19d7d84e0af8.png" width="401" height="351" alt="World of Warcraft®">
  <br />
  My add-ons for World of Warcraft®.
</p>

---

## Mainline

Add-ons compatible with WoW Mainline.

- [**Fastbind**](/addons/Fastbind)
- [**Tunnelvision**](/addons/Tunnelvision)

## Classic

Add-ons compatible with WoW Classic.

- [**Dangeradar**](/addons/Dangeradar)
- [**Fastbind**](/addons/Fastbind)
- [**Tunnelvision**](/addons/Tunnelvision)

## Development

To install all add-ons via symbolic link, use the script `Install.ps1`. Launch a PowerShell prompt and execute the snippet below, changing the game installation path accordingly.

```psh
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\Install.psq -Game "C:\World of Warcraft"
```

Please note;

1. The tooling is designed to work in a Unix environment, like WSL, not Windows.
2. This repository tracks several different add-ons.
3. Never commit changes to multiple add-ons at the same time.
4. Commits **should** link to one or more existing issues, e.g. `Bump interface compatibility #11`.
5. Tags **must** follow the format `platform/name/version`, e.g. `classic/Tunnelvision/1.0.0`.

### Manifest (ToC files)

1. Supported game instances are derived from the presence of their respective suffixed ToC file. For example, if you have an add-on with a single, non-suffixed ToC file `AddOn.toc` then the conclusion is that the add-on only supports Mainline. But if you have two ToC files, one non-suffixed and one suffixed with TBC then the conclusion is the add-on only supports Mainline and TBC. See <https://wowpedia.fandom.com/wiki/TOC_format> for more information on ToC suffixes.
2. You must always have at least one non-suffixed ToC file.

### Linting

Both Lua and XML files must pass through validation.

```sh
scripts/lint <directory>
```

The script will recursively walk the given directory looking for files to validate, report and exit with a non-zero status if issues are encountered.

### Releases

Do **not** ever edit versions manually! Use the script:

```sh
scripts/release [-h|-p|-m|-M] <path>
```

This will bump the version string of given add-on, commit it, tag it and push to the remote respository, which will trigger a new automated release. Options `-p`, `-m`, or `-M` stand for patch, minor, or major release respectively. Patch version counts the commits since last release. Minor and major versions are increments of one on top of the current version.

## .curseforge file

Each add-on should have a `.curseforge` file containing information about the project on CurseForge as JSON. Example:

```json
{
  "projectId": 344402,
  "releaseType": "release",
  "changelog": "",
  "changelogType": "markdown",
  "gameVersions": [9094, 9894, 9919]
}
```

This information is then used during release to upload the new archive via API.

### CurseForge game version

Find game version IDs using `curl` and `jq`:

```sh
export CURSEFORGE_API_TOKEN=...
curl -s https://wow.curseforge.com/api/game/versions -H "X-Api-Token: $CURSEFORGE_API_TOKEN" \
  | jq '.[] | select([.apiVersion] | inside(["100105","30402","11403"])).id'
```

## Legal

The MIT License © 2017 Arthur Corenzan

These Add-ons are not created by, affiliated with or sponsored by Blizzard Entertainment, Inc. or its affiliates. The World of Warcraft® and related logos are registered trademarks or trademarks of Blizzard Entertainment, Inc. in the United States and/or other countries. All rights reserved.
