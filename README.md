# Switch: Google Cloud Configuration Management Tool

Switch is a macOS bash script that simplifies the management of multiple Google Cloud configurations by enabling the creation of user-friendly shortcuts. It facilitates easy switching between various Google Cloud accounts and projects through straightforward command shortcuts. While the gcloud CLI offers similar functionality, this script streamlines the process, making it more memorable and helping you confirm the configuration switch, particularly useful for individuals handling multiple Google accounts for various services, such as managing numerous GCP services hosted across unique google accounts.

## Supported Platform
- macOS

## Pre-requisites
1. Before creating a profile auth the google account you want to switch to in the [Google CLI](https://cloud.google.com/sdk/gcloud#download_and_install_the)
```
gcloud auth login
```
Note: This will open a web browser window where you can sign in with your Google account.
Once you've signed in, you'll be redirected back to the terminal and your new account will be authorized for use with gcloud

2. Get your Property ID for the google account you want to switch to at the [Google Cloud Console](http://console.cloud.google.com)
 
## Features
- Create, update, and remove shortcuts for Google Cloud configurations.
- Display information about all configured shortcuts.
- Execute shortcuts to quickly switch between Google Cloud configurations.

## Installation
1. Clone the repo `git clone https://github.com/danielraffel/switch.git` on your local machine.
2. Change directories `cd switch`
3. Rename and move the script to use switch as a global command `sudo cp switch.sh /usr/local/bin/switch`
4. Ensure the script is executable: `sudo chmod +x /usr/local/bin/switch`
5. Update the PATH in ~/.bashrc and/or ~/.zshrc profile
```
echo 'export PATH="/usr/local/bin:$PATH"' | cat - ~/.bashrc > temp && mv temp ~/.bashrc
echo 'export PATH="/usr/local/bin:$PATH"' | cat - ~/.zshrc > temp && mv temp ~/.zshrc
```
6. Reload the configurations
```
source ~/.bashrc
source ~/.zshrc
```

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

## How to Remove Everything Switch Installed
To completely remove switch from your system:
1. Delete the script you copied `/usr/local/bin/switch`.
2. Delete the repo you cloned `/path/to/switch`.
3. Remove the PATH `export PATH="/usr/local/bin:$PATH"` from `.bashrc` and/or `.zshrc`.
4. Remove the file `~/.switch_config` with your configurations
5. Remove the directory `~/.switch_shortcuts` with your shortcuts

## Note
This script is specifically designed for managing Google Cloud configurations on macOS. Please ensure you have the necessary permissions to modify `/usr/local/bin` and other system directories.
