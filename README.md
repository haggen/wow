# My add-ons for World of Warcraft®

| Add-on           | Description                    | Supported game version   |                                                                                                                                                  |
| ---------------- | ------------------------------ | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Dangeradar**   | Watch out for danger.          | Wrath                    | [CurseForge](https://www.curseforge.com/wow/addons/dangeradar) — [Source](/addons/Dangeradar) — [Download](/releases?q=Dangeradar)               |
| **Tunnelvision** | For people with tunnel vision. | Wrath, Classic           | [CurseForge](https://www.curseforge.com/wow/addons/tunnelvision-focused) — [Source](/addons/Tunnelvision) — [Download](/releases?q=Tunnelvision) |
| **Fastbind**     | Change your keybindings, fast. | Mainline, Wrath, Classic | [CurseForge](https://www.curseforge.com/wow/addons/fastbind) — [Source](/addons/Fastbind) — [Download](/releases?q=Fastbind)                     |

## Development

### Linking

During development, it's best if we link add-ons from WSL to the game directory. Copy the script `Linker.ps1` into a Windows directory, launch a PowerShell prompt there, and execute:

```psh
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\Linker.ps1 -Game "C:\World of Warcraft\_retail_" -AddOn "\\wsl.localhost\Ubuntu-22.04\wow\src\Tunnelvision"
```

### Tooling

The tooling is designed to work in a Unix environment, like WSL, not Windows.

There are several Bash scripts to help development, packaging, and distribution of the add-ons. See the [scripts](/scripts) directory for more information.

It also includes workspace settings for VSCode and recommended extensions.

#### Pitfalls

The scripts test a lot of things but also assume things about the state of the repository.

- Tag are expected to follow the format `Add-on/v123`.
- ...

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

The script will recursively walk the given directory looking for files to validate, report, and exit with a non-zero status if any issues are encountered.

#### Release

Do **not** ever edit versions manually! Use the script:

```sh
scripts/release <path>
```

This script will bump the version of the add-on in all ToC files, commit it, tag the commit, and push it to remote.

GitHub actions will trigger a pipeline that will package the add-on, generate a changelog, and upload it to both GitHub and CurseForge.

#### CurseForge

Each add-on should have a `.curseforge` file containing information about the project on CurseForge as JSON. Example:

```json
{
  "projectId": 344402,
  "releaseType": "release",
  "changelog": "",
  "changelogType": "markdown"
}
```

This information is then used during release to upload the file to CurseForge via API.

#### Unreleasing

In case the CI fails you need to undo the release commit and tag, fix the workflow and try again. This is because the CI will use the workflow at the time of the commit and not the latest version.

```sh
scripts/unrelease <tag>
```

This will undo the commit and delete the tags both locally and remotely.

## Legal

The MIT License © 2017 Arthur Corenzan

These Add-ons are not created by, affiliated with, or sponsored by Blizzard Entertainment, Inc. or its affiliates. The World of Warcraft® and related logos are registered trademarks or trademarks of Blizzard Entertainment, Inc. in the United States and/or other countries. All rights reserved.
