# My add-ons for World of Warcraft®

| Add-on           | Description                    | Supported game version |                                                                       |
| ---------------- | ------------------------------ | ---------------------- | --------------------------------------------------------------------- |
| **Dangeradar**   | Watch out for danger.          | Classic                | [Source](/addons/Dangeradar) — [Download](/releases?q=Dangeradar)     |
| **Fastbind**     | Change your keybindings, fast. | Mainline, Classic      | [Source](/addons/Fastbind) — [Download](/releases?q=Fastbind)         |
| **Tunnelvision** | For people with tunnel vision. | Mainline, Classic      | [Source](/addons/Tunnelvision) — [Download](/releases?q=Tunnelvision) |

## Development

### Linking

During development, it's best if we link add-ons from WSL to the game directory. Launch a PowerShell prompt and execute the snippet below, changing the paths accordingly.

```psh
New-Item "C:\World of Warcraft\_classic_era_\Interface\AddOns\Tunnelvision" -ItemType SymbolicLink -Target "\\wsl.localhost\Ubuntu-22.04\wow\src\Tunnelvision"
```

### Tooling

The tooling is designed to work in a Unix environment, like WSL, not Windows.

There are several Bash scripts to help development, packaging and distribution of the add-ons. See the [scripts](/scripts) directory for more information.

It also includes workspace settings for VSCode and recommended extensions.

### Workflow

The repository tracks several different add-ons.

To keep a clean history and allow for generated changelogs you should never commit changes to multiple add-ons at the same time.

Also, commits you wish to include in the changelog should mention an issue from GitHub, e.g. Add new feature #42.

There are some guidelines you need to follow regarding source files.

#### Supported game versions

Additional supported game versions are configured by providing suffixed ToC files. See <https://wowpedia.fandom.com/wiki/TOC_format> for more information.

Also, you must always provide at least one main ToC file, without suffixes.

#### Linting

Both Lua and XML files must pass validation.

```sh
scripts/lint <path>
```

The script will recursively walk the given directory looking for files to validate, report and exit with a non-zero status if any issues are encountered.

#### Release

Do **not** ever edit versions manually! Use the script:

```sh
scripts/release <path>
```

This script will bump the version of the add-on in all ToC files, commit it, tag the commit and push it to remote.

GitHub actions will trigger a pipeline that will package the add-on, generate a changelog and upload it to both GitHub and CurseForge.

#### CurseForge

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

You can find the game version IDs you should use with `curl` and `jq`:

```sh
export CURSEFORGE_TOKEN=...
curl -s https://wow.curseforge.com/api/game/versions -H "X-Api-Token: $CURSEFORGE_TOKEN" \
  | jq '.[] | select([.apiVersion] | inside(["100105","30402","11403"])).id'
```

## Legal

The MIT License © 2017 Arthur Corenzan

These Add-ons are not created by, affiliated with or sponsored by Blizzard Entertainment, Inc. or its affiliates. The World of Warcraft® and related logos are registered trademarks or trademarks of Blizzard Entertainment, Inc. in the United States and/or other countries. All rights reserved.
