<p align="center"><img src="wow.png" width="640"></p>
<p align="center">My add-ons for World of Warcraft®. <a href="https://travis-ci.org/haggen/wow"><img src="https://travis-ci.org/haggen/wow.svg?branch=master" valign="middle"></a></p>

---

## Classic

Add-ons compatible with WoW Classic (1.13).

- **[Threatrack](/classic/Threatrack) `*NEW*`**
- **[Fastbind](/classic/Fastbind)**
- **[Focused](/classic/Focused)**
- **[Developer](/classic/Developer)**

## Development

This is a monorepo, meaning it contains multiple add-ons in the same repository. For this reason and more there are some guidelines we should follow:

- Avoid commiting changes in more than one add-on at a time.
- Tags must use the format `platform/name/version`.
- Scripts should be sensible the multi-project nature of the repository.
- Create issues and branches containing the issue reference for each _unit_ of work such as a new feature, a fix, a change or chores.

## Linters

There are scripts to validate both Lua and XML files:

```shell
scripts/validate-lua <directory>
scripts/validate-xml <directory>
```

These scripts will recursively walk the given directory looking for files to validate and exit non-zero status when they fail.

They're also automatically ran for every push thanks to [Travis](https://travis-ci.org).

## Release

Releases loosely follow the [semantic versioning](https://semver.org/) system. Always have the bump of a version in its own commit and always tag it. Actually, there's a script for that.

```shell
scripts/release [-h|-p|-m|-M] <path>
```

`scripts/release` will bump the version for given add-on, commit it, tag it and push the change to the remote respository. Use the options `-p`, `-m`, or `-M` for patch, minor, or major releases respectively. Minor and major are increments of one. Patch releases count the commits since last version.

## Legal

The MIT License © 2017 Arthur Corenzan

These Add-ons are not created by, affiliated with or sponsored by Blizzard Entertainment, Inc. or its affiliates. The World of Warcraft® and related logos are registered trademarks or trademarks of Blizzard Entertainment, Inc. in the United States and/or other countries. All rights reserved.
