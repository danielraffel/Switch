# gSwitcher: Google Cloud Configuration Management Tool

gSwitcher is a macOS bash script that simplifies the management of multiple Google Cloud configurations by enabling the creation of user-friendly shortcuts. It facilitates easy switching between various Google Cloud accounts and projects through straightforward command shortcuts. While the gcloud CLI offers similar functionality, this script streamlines the process, making it more memorable and helping you confirm the configuration switch, particularly useful for individuals handling multiple Google accounts for various services, such as managing numerous GCP services hosted across unique google accounts.

## Supported Platform
- macOS

## Features
- Create, update, and remove shortcuts for Google Cloud configurations.
- Display information about all configured shortcuts.
- Execute shortcuts to quickly switch between Google Cloud configurations.

## Installation
1. Clone or download the `gSwitcher.sh` script to your local machine.
2. Ensure the script is executable: `chmod +x /path/to/gSwitcher.sh`
3. Optionally, add an alias in your `.bashrc` or `.zshrc`: `alias switch='/path/to/gSwitcher.sh'`

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
To completely remove gSwitcher from your system:
1. Delete the `gSwitcher.sh` script.
2. Remove the related alias from `.bashrc` or `.zshrc`.
3. Optionally, remove the `gswitcher` directory from `/usr/local/bin` if no longer needed.

## Note
This script is specifically designed for managing Google Cloud configurations on macOS. Please ensure you have the necessary permissions to modify `/usr/local/bin` and other system directories.
