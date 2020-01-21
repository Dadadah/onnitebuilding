# OnniteBuilding
Onnite Building is a package for Blue Mountains's game Onset designed to mirror the building mechanics of Epic Game's Fortnite.

![headline image of onnite](https://user-images.githubusercontent.com/22386163/72674038-5ad4f080-3a2f-11ea-9206-00d8085b0618.png)

## License
This code is licensed by [GNU GPL-V3](https://github.com/Dadadah/onnitebuilding/blob/master/LICENSE)

## Installation
To install this package into your Onset server, download the latest release [here](https://github.com/Dadadah/onnitebuilding/releases). Put the contents of the release into your server's `packages` folder and add the package to your server's `server_config.json`.

## Configuration
There are two configuration variables that you should change. Both of these variables can be found on the top of [server/construct.lua](https://github.com/Dadadah/onnitebuilding/blob/master/server/construct.lua). The first is `admins_remove`. This is a list of accounts that can remove all props. The second is `prop_limit`. This is the maximum constructs that any one player can have.

## In-Game Controls
| Key         	| Action              	|
|-------------	|---------------------	|
| Y           	| Toggle Construction 	|
| E           	| Toggle Removal Mode 	|
| R           	| Rotate Construction 	|
| Mouse Wheel 	| Change Construction 	|
| Left Click  	| Place Construction  	|

## Contributing
Contributions are welcome on this project, however they will be expected to be high quality contributions and high quality code. I reserve the right to deny code changes if I choose to do so.

## Bugs/Issues
If you encounter a bug, please create a GitHub Issue [here](https://github.com/Dadadah/onnitebuilding/issues).

## Known Conflicts
This mod conflicts with the following mod(s):
* onset-construction
