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

2. Get your [Project ID](https://support.google.com/googleapi/answer/7014113?hl=en) for the Google account you want to switch to in the [Google Cloud Console](http://console.cloud.google.com)
 
## Features
- Create, update, and remove shortcuts for Google Cloud configurations associated with your Google accounts.
- Display information about all configured shortcuts, including an asterisk (*) next to the currently active shortcut.
- Execute shortcuts to quickly switch between Google Cloud configurations associated with your Google accounts.
- Manage SSH commands for each shortcut, allowing easy SSH access to VMs associated with each shortcut.
- Export and import Switch configurations, making the setup portable across different machines.

## Installation
1. Clone the repo on your local machine
```
git clone https://github.com/danielraffel/switch.git
``` 
2. Change directories
```
cd switch
```
3. Rename and move the script to use switch as a global command
```
sudo cp switch.sh /usr/local/bin/switch
```
4. Ensure the script is executable
```
sudo chmod +x /usr/local/bin/switch
```
5. Update the PATH in ~/.bashrc and/or ~/.zshrc profile
```
echo 'export PATH="/usr/local/bin:$PATH"' | cat - ~/.bashrc > temp and mv temp ~/.bashrc
echo 'export PATH="/usr/local/bin:$PATH"' | cat - ~/.zshrc > temp and mv temp ~/.zshrc
```
6. Reload the configurations
```
source ~/.bashrc
source ~/.zshrc
```

## Why Use Switch?
### Before Switch
Switching between multiple Google Cloud accounts and projects typically required a series of `gcloud` commands:
```
gcloud config set account $account
gcloud config set project $project
gcloud config get-value account
gcloud config get-value project
```
This process was not only time-consuming but also prone to errors, especially when recalling specific account and project details.

### After Switch
[One Time Process] Create a memorable shortcut for your Google Cloud configuration:
```
switch create myShortcut
```
Execute the shortcut:
```
switch myShortcut
```
This not only handles all the necessary commands but also provides a description of the projects running on that account, which can be updated anytime. It turns a multi-step gCloud process into a simple one-command action, ensuring you are always in the right account with the right configuration. **Given that I frequently don't touch some infra for months at a time this is very handy when I need to access resources at the command line.**

## How To Use Switch
### Create a new shortcut
This will allow you to create a custom shortcut associated with a Google Cloud account/project you want to switch to at the command line.
```
switch create myShortcut
```

### Execute a shortcut
This will allow you to switch to the account/project associated with your custom shortcut.
```
switch myShortcut
```

### Display information about all shortcuts
This will display all the custom shortcuts you've created along with their respective email addresses, property ID, descriptions associated with them and any ssh command you might have added. An asterisk (*) is shown next to the currently active shortcut.
```
switch info
```

### Update the description of an existing shortcut
This will allow you to update the description (of what's running on GCP) associated with this shortcut. It helps quickly grok what's running on that account.
```
switch update myShortcut
```

### Display Help
This will allow you to learn about all the commands switch supports.
```
switch help
```

### Manage SSH Commands
Add an SSH command to the current active shortcut so you can use it later to SSH in quickly.
```
switch add ssh user@example.com
```
Execute the SSH command associated with the current active shortcut so you can SSH in quickly.
```
switch ssh
```
Remove the SSH command from the current active shortcut.
```
switch remove
```

### Export/Import Configuration
Export the current configuration by giving it a name.
```
switch export /path/to/name_your_config_filename
```
Import configuration from a specified file.
```
switch import /path/to/your_config_filename
```

### Remove a shortcut
This will allow you to delete a custom shortcut you've created.
```
switch remove myShortcut
```

## How to Manually Remove Everything Switch Installed
To completely remove switch from your system:
1. Delete the script you copied `/usr/local/bin/switch`
2. Delete the repo you cloned `/path/to/switch`
3. Remove the PATH `export PATH="/usr/local/bin:$PATH"` from `.bashrc` and/or `.zshrc`
4. Remove the file with your configurations `~/.switch_config`
5. Remove the directory with your shortcuts `~/.switch_shortcuts`

## Note
This script is specifically designed for managing Google Cloud configurations on macOS. It should be trivial to adapt to other platforms. Please ensure you have the necessary permissions to modify `/usr/local/bin` and other system directories.
