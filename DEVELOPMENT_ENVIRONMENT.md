# A320 NORMAL CHECKLIST Developer Notes
Link to the up-to-date version of this document: [DEVELOPMENT_ENVIRONMENT.md](https://github.com/VerticalLongboard/xplane-a320-checklist/blob/main/DEVELOPMENT_ENVIRONMENT.md)

## Development Environment
### Motivation
If you happen to develop FlyWithLua plugins and are crossing the threshold from "coding a bit and pressing buttons to see if my plugin works" to "I don't like LUA too much, but it's doing its job and I like to code a bit more", feel free to use and adapt the VS Code / LuaUnit environment boilerplate from A320 NORMAL CHECKLIST.

Perks:
* **Linting** and colors while coding
* **Testing** as you're used to
* Pressing **Build** runs all tests, copies the script and dependencies to X-Plane and triggers a running X-Plane instance to reload all scripts
* Building a **release package** is only one button away (ZIP + Installer)
* Takes about 15 minutes (including downloads) to set up

![FlyWithLua Boilerplate Screenshot](DEVELOPMENT_ENVIRONMENT.png "FlyWithLua Boilerplate Screenshot")

### Setup
Required (Coding + Testing):
* Vanilla Current Windows
* Visual Studio Code: https://code.visualstudio.com/
* VS Code extensions:
  * vscode-lua (linting): https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua
* Lua: https://github.com/rjpcomputing/luaforwindows
* Download the A320 NORMAL CHECKLIST repository and open the workspace in VS Code!
* Run default build task via **CTRL+SHIFT+B** once and update local paths in:
  * `<repository root>/LOCAL_ENVIRONMENT_CONFIGURATION.cmd`

Optional (Running + Packaging):
* git: https://git-scm.com/ (Versioning)
* 7zip: https://www.7-zip.org/ (ZIP release package)
* NSIS: https://nsis.sourceforge.io/ (EXE release installer)
* Packetsender: https://packetsender.com/ (X-Plane remote command interface)
* VS Code extensions:
  * Code Runner (lets you run selected snippets of code): https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner
  * NSIS (linting): https://marketplace.visualstudio.com/items?itemName=idleberg.nsis
* Update local paths and plugin name in:
  * `<repository root>/LOCAL_ENVIRONMENT_CONFIGURATION.cmd`
  * `<repository root>/build_configuration.cmd`
  
## How-To
### Build
To build your plugin (and copy it to your locally running X-Plane instance), press **CTRL+SHIFT+B**, which runs the default build task.

### Generate Release Package
Creating a release package is done via pressing **CTRL+P** and typing `task packReleasePackage` into the little command panel that pops up.

## Observations and Hints
### Lua
After spending a few hours with LUA, it appears LUA looks like Turbo Pascal and tries to be JavaScript. It ends up having the disadvantages of both:
* Not being required to define variables is neither cool nor elegant. Up the test coverage to close to 100% when writing LUA. Nil.
* Write more inter-module tests than you're used to, because you can easily nil-disconnect two (mentally) coupled components. Coupling is not a bad thing, especially when it is intentional.
* Everything is global by default (yes, even things defined in anonymous functions inside a function that sits in a table), polluting your namespace. Dependency Hell Yeah! Feels like writing Assembly that is supposed to run in a JRE.
* { Can you read this question? } then Better write this instead! end
* From the official documentation: "_Lua has no integer type, as it does not need it._". One famous last quote of a software engineer, before he starts writing either a non-trival search engine or anything related to geometric algebra (games anyone?). Floating point numbers are not magical, their nature is naturally well-defined and leaves many minds in nearly religious disbelief. At least newer versions can be compiled with integer support.
* Running `self.variable = nil print(self.variable)` can, under certain circumstances (broken pattern matching somewhere else in the code), output something that is **not** `nil`. Tested with Lua 5.1 and Lua 5.4. You have been warned.

Nonetheless:
* It doesn't immediately shoo away both people who developed software before and those who didn't.
* There's automatic memory management and it is relatively easy to create something that remotely resembles components. That's good.
* Many platforms use it because it's easy to embed. Also, when running it on LuaJIT (like FlyWithLua), copying files in a build takes longer than running a full test suite plus the script itself, cutting iteration times to almost zero.
