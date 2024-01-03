# Switch: Google Cloud Configuration Management Tool

Switch is a macOS bash script that simplifies the management of multiple Google Cloud configurations by enabling the creation of user-friendly shortcuts. It facilitates easy switching between various Google Cloud accounts and projects through straightforward command shortcuts. While the gcloud CLI offers similar functionality, this script streamlines the process, making it more memorable and helping you confirm the configuration switch, particularly useful for individuals handling multiple Google accounts for various services, such as managing numerous GCP services hosted across unique google accounts.

## Supported Platform
- macOS

## Pre-requisites

## Features
- Create, update, and remove shortcuts for Google Cloud configurations.
- Display information about all configured shortcuts.
- Execute shortcuts to quickly switch between Google Cloud configurations.

## Installation
1. Clone the repo `git clone https://github.com/danielraffel/switch.git` on your local machine.
2. Change directories `cd switch`
3. Ensure the script is executable: `chmod +x switch.sh`
4. Run the following command to change the ownership of the script and make it executable without sudo:
```
sudo chown $USER switch.sh
chmod +x switch.sh
```
5. Optionally, add an alias in your `.bashrc` or `.zshrc`: `alias switch='/path/to/switch.sh'`

## Usage
- To create a new shortcut: `switch create [shortcut_name]`
- To update an existing shortcut: `switch update [shortcut_name]`
- To remove a shortcut: `switch remove [shortcut_name]`
- To display information about all shortcuts: `switch info`
- To execute a shortcut: `switch [shortcut_name]`

### Example
#### Create a new shortcut
`switch create myShortcut`

#### Update an existing shortcut
`switch update myShortcut`

#### Remove a shortcut
`switch remove myShortcut`

#### Display information about all shortcuts
`switch info`

#### Execute a shortcut
`switch myShortcut`

## Removal of gSwitcher
To completely remove switch from your system:
1. Delete the `switch.sh` script.
2. Remove the related alias from `.bashrc` or `.zshrc`.
3. Optionally, remove the `switch` directory from `/usr/local/bin` if no longer needed.

## Note
This script is specifically designed for managing Google Cloud configurations on macOS. Please ensure you have the necessary permissions to modify `/usr/local/bin` and other system directories.
