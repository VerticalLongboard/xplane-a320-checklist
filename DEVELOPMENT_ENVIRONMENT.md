# A320 NORMAL CHECKLIST Developer Notes

## Development Environment
If you happen to develop FlyWithLua plugins and are crossing the threshold from "coding a bit and pressing buttons to see if my plugin works" to "I don't like LUA too much, but it's doing its job and I like to code a bit more", feel free to use and adapt the VS Code / LuaUnit environment boilerplate from A320 NORMAL CHECKLIST.

Perks:
* Linting and colors while coding
* Testing as you're used to
* Pressing "Build" runs all tests, copies the script to X-Plane and triggers a running X-Plane instance to reload all scripts
* Building a release package is only one button away (ZIP + Installer)
* Takes about 15 minutes (including downloads) to set it up

### Setup
Required (Coding + Testing):
* Vanilla Windows 10
* Visual Studio Code: https://code.visualstudio.com/
* Install Lua: https://github.com/rjpcomputing/luaforwindows
* Run at least one task and update local paths and your plugin name in:
  * `<repository root>/LOCAL_ENVIRONMENT_CONFIGURATION.cmd`
  * `<repository root>/build_configuration.cmd`

Optional (Versioning, Release Packaging, On-the-fly Script Reloading):
* git: https://git-scm.com/
* Install 7zip: https://www.7-zip.org/
* Install NSIS: https://nsis.sourceforge.io/
* Install Packetsender: https://packetsender.com/
* Install VS Code extensions:
  * vscode-lua (linting): https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua
  * Code Runner (lets you run selected snippets of code): https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner
  * NSIS (linting): https://marketplace.visualstudio.com/items?itemName=idleberg.nsis
* Update paths if required

Clone the A320 NORMAL CHECKLIST repository and open the workspace in VS Code!
