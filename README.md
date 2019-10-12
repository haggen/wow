<p align="center"><img src="wow.png" width="640"></p>
<p align="center">My add-ons for World of Warcraft®. <a href="https://travis-ci.org/haggen/wow"><img src="https://travis-ci.org/haggen/wow.svg?branch=master" valign="middle"></a></p>

---

## Classic

Add-ons compatible with WoW Classic (1.13).

- [**Threatrack**](/classic/Threatrack)
- [**Fastbind**](/classic/Fastbind)
- [**Focused**](/classic/Focused)
- [**Developer**](/classic/Developer)

## Development

This is a monorepo, meaning it tracks several add-ons for different version of WoW in the same repository. As such some of the common assumptions about a repository don't hold.

- Always use separate commits for changes in different projects.
- Tags must follow the format `platform/name/version`.
- Working branches should be named after an existing issue, e.g. `issue-11`.

## Linters

There are scripts to validate both Lua and XML files:

```shell
scripts/validate-lua <directory>
scripts/validate-xml <directory>
```

These scripts will recursively walk the given directory looking for files to validate and exit non-zero status if they fail.

They're also automatically ran for every push thanks to [Travis](https://travis-ci.org).

## Release

Releases loosely follow [semantic versioning](https://semver.org/). Do not edit versions manually. Use the script:

```shell
scripts/release [-h|-p|-m|-M] <path>
```

This will bump the specified version for given add-on, commit it, tag it and push to the remote respository. Options `-p`, `-m`, or `-M` stand for patch, minor, or major release respectively. Minor and major are increments of one. Patch releases count the commits since last release.

## Legal

The MIT License © 2017 Arthur Corenzan

These Add-ons are not created by, affiliated with or sponsored by Blizzard Entertainment, Inc. or its affiliates. The World of Warcraft® and related logos are registered trademarks or trademarks of Blizzard Entertainment, Inc. in the United States and/or other countries. All rights reserved.
