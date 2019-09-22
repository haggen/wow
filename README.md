<p align="center"><img src="wow.jpg" width="400"></p>
<p align="center">My add-ons for World of Warcraft™. <a href="https://travis-ci.org/haggen/wow"><img src="https://travis-ci.org/haggen/wow.svg?branch=master" valign="middle"></a></p>

---

## Classic

Add-ons compatible with WoW Classic (1.13).

- [Threatrack](/classic/Threatrack) `*NEW*`
- [Fastbind](/classic/Fastbind)
- [Focused](/classic/Focused)
- [Developer](/classic/Developer)

## Development

This is a monorepo, meaning there are multiple add-ons in the same repository. As such avoid commiting changes in separated add-ons at the same time and always specify which project a release tags must is refering to. Also remember to run linters before commiting.

```shell
scripts/validate-lua <path>
scripts/validate-xml <path>
```

These scripts will recursively walk the directory looking for files to validate and exit non-zero if the they don't pass.

## Legal

The MIT License © 2017 Arthur Corenzan

These Add-ons are not created by, affiliated with or sponsored by Blizzard Entertainment, Inc. or its affiliates. The World of Wacraft® and related logos are registered trademarks or trademarks of Blizzard Entertainment, Inc. in the United States and/or other countries. All rights reserved.
