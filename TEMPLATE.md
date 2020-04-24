# omapp-v3 template

This is a template for creating multiplatform apps based on the om tools, and libs.

## Create a new app/game
On github: "Use this template"
Manual: git pull ... don't clone // :TODO: fix

## Next steps
- [ ] Update the README.md
- [ ] Init, and Update the submodules ```git submodule update --init --recursive```

## Getting template updates

Usually we do not update the game once created from the template,
but sometimes you might want to pull in fixes. Be sure you know what you do.

You can add a new remote
```git remote add template git@github.com:AndreasOM/omapp-v3.git```
the fetch the newest version
```git fetch template```
and rebase your branch on that
```git rebase template/master```

Again, better know what you are doing, and be sure you actually want to do that!


## Random :TODO:

We are currently experimenting with xcodegen [https://github.com/yonaskolb/XcodeGen] to generate the project files.
