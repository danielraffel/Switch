#!/bin/bash

# Directory for the shortcuts
SHORTCUT_DIR="$HOME/.switch_shortcuts"

# Path to store the configuration details
CONFIG_FILE="$HOME/.switch_config"

# Path to store SSH commands
SSH_CONFIG_FILE="$HOME/.switch_ssh_config"

# Ensure the configuration file, SSH config, and shortcut directory exist
mkdir -p "$SHORTCUT_DIR"
touch "$CONFIG_FILE"
touch "$SSH_CONFIG_FILE"

# Function to add the shortcut directory to PATH if not already present
add_to_path() {
    if [[ ! -d "$SHORTCUT_DIR" ]]; then
        mkdir -p "$SHORTCUT_DIR"
    fi

    if ! echo "$PATH" | grep -q "$SHORTCUT_DIR"; then
        export PATH="$PATH:$SHORTCUT_DIR"
        # Add this to .bashrc or .zshrc for persistence
        echo "export PATH=\"\$PATH:$SHORTCUT_DIR\"" >> "$HOME/.bashrc"
        echo "export PATH=\"\$PATH:$SHORTCUT_DIR\"" >> "$HOME/.zshrc"
    fi
}

# Call the function to ensure SHORTCUT_DIR is in PATH
add_to_path

# Function to display help
display_help() {
    echo "Switch - Quickly Change Google Cloud Configurations"
    echo "Usage:"
    echo "  switch create [name] - Create a new shortcut"
    echo "  switch update [name] - Update an existing shortcut"
    echo "  switch remove [name] - Remove an existing shortcut"
    echo "  switch info - Display information about all shortcuts"
    echo "  switch [name] - Activate the specified shortcut"
    echo "  switch add [SSH command] - Add an SSH command to the current active shortcut"
    echo "  switch remove - Remove the SSH command from the current active shortcut"
    echo "  switch ssh [cmd] [shortcut] - Show and execute the SSH command for the current or specified shortcut"
    echo "  switch ssh cmd - Show the SSH command for the current shortcut"
    echo "  switch ssh cmd [shortcut] - Show the SSH command for the specified shortcut"
    echo "  switch keygen - Remove the old host key for the current SSH command's IP address"
    echo "  switch help - Display this help message"
}

# Enhanced for flexible yes/no input
prompt_for_input() {
    local input_var=$1
    local prompt_message=$2

    while true; do
        echo "$prompt_message"
        read "$input_var"
        echo "You entered: ${!input_var}"
        read -p "Is this correct? (yes/no): " confirmation
        case $confirmation in
            [Yy]* ) break;;  # Accepts y, Y, yes, Yes, etc.
            [Nn]* ) echo "Please enter the correct information.";;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to create a new shortcut
create_shortcut() {
    local shortcut_name=$1

    # Check for empty shortcut name
    if [[ -z "$shortcut_name" ]]; then
        echo "Please provide a name for the shortcut."
        return
    fi

    # Check for existing shortcut
    if grep -q "^$shortcut_name:" "$CONFIG_FILE"; then
        echo "Shortcut '$shortcut_name' already exists."
        return
    fi

    # Request gCloud account and project
    prompt_for_input account "Enter the gCloud account (eg gmail address): "
    prompt_for_input project "Enter the gCloud project ID: "
    
    # Request description of what will be running on the infra
    prompt_for_input description "Enter a description for this setup: "

    # Create the shortcut script
    local script_path="$SHORTCUT_DIR/$shortcut_name"
    echo "#!/bin/bash" > "$script_path"
    echo "gcloud config set account $account" >> "$script_path"
    echo "gcloud config set project $project" >> "$script_path"
    echo "gcloud config get-value account" >> "$script_path"
    echo "gcloud config get-value project" >> "$script_path"
    chmod +x "$script_path"

    # Save the configuration details
    echo "$shortcut_name:$account:$project:$description" >> "$CONFIG_FILE"

    echo "Shortcut '$shortcut_name' created successfully."
}

# Function to update an existing shortcut with the option to change the shortcut name
update_shortcut() {
    local shortcut_name=$1

    # Check for empty shortcut name
    if [[ -z "$shortcut_name" ]]; then
        echo "Please provide the name of the shortcut to update."
        return
    fi

    # Check if the shortcut exists
    if ! grep -q "^$shortcut_name:" "$CONFIG_FILE"; then
        echo "Shortcut '$shortcut_name' does not exist."
        return
    fi

    echo "Do you want to update the shortcut name from '$shortcut_name'? (yes/no)"
    read update_name_confirm
    if [[ "$update_name_confirm" =~ ^[Yy] ]]; then
        while true; do
            echo "What name do you want to update the shortcut to:"
            read new_shortcut_name
            echo "You entered: $new_shortcut_name"
            echo "Is this correct? (yes/no)"
            read confirm_new_name
            if [[ "$confirm_new_name" =~ ^[Yy] ]]; then
                if grep -q "^$new_shortcut_name:" "$CONFIG_FILE"; then
                    echo "A shortcut with the name '$new_shortcut_name' already exists. Please choose a different name."
                else
                    # Rename in CONFIG_FILE and SSH_CONFIG_FILE if exists
                    sed -i '' "s/^$shortcut_name:/$new_shortcut_name:/" "$CONFIG_FILE"
                    if grep -q "^$shortcut_name:" "$SSH_CONFIG_FILE"; then
                        sed -i '' "s/^$shortcut_name:/$new_shortcut_name:/" "$SSH_CONFIG_FILE"
                    fi
                    # Rename the shortcut script file
                    mv "$SHORTCUT_DIR/$shortcut_name" "$SHORTCUT_DIR/$new_shortcut_name"
                    shortcut_name=$new_shortcut_name
                    echo "Shortcut name updated successfully."
                    break
                fi
            elif [[ "$confirm_new_name" =~ ^[Nn] ]]; then
                echo "Please enter the name again."
            else
                echo "Invalid response. Please answer 'yes' or 'no'."
            fi
        done
    fi

    # Proceed with other updates (Account, Project ID, Description)
    # Extract current account and project
    current_account=$(grep "^$shortcut_name:" "$CONFIG_FILE" | cut -d ':' -f 2)
    current_project=$(grep "^$shortcut_name:" "$CONFIG_FILE" | cut -d ':' -f 3)

    echo "Current account: $current_account"
    echo "Current project: $current_project"
    # Optional: Prompt for updating account and project if needed

    # Request new description
    prompt_for_input new_description "Enter a new description for this setup: "
    # Update the configuration file with new details
    sed -i '' "s/^$shortcut_name:.*/$shortcut_name:$current_account:$current_project:$new_description/" "$CONFIG_FILE"

    echo "Shortcut '$shortcut_name' updated successfully."
}


# Function to remove an existing shortcut
remove_shortcut() {
    local shortcut_name=$1

    # Check for empty shortcut name
    if [[ -z "$shortcut_name" ]]; then
        echo "Please provide the name of the shortcut to remove."
        return
    fi

    # Confirm removal
    echo "Are you sure you want to remove shortcut '$shortcut_name'? (yes/no)"
    read confirmation
    if [[ "$confirmation" != "yes" ]]; then
        echo "Removal cancelled."
        return
    fi

    # Ensure the shortcut exists within the controlled environment
    if [[ -f "$SHORTCUT_DIR/$shortcut_name" ]]; then
        rm "$SHORTCUT_DIR/$shortcut_name"
        sed -i '' "/^$shortcut_name:/d" "$CONFIG_FILE"
        echo "Shortcut '$shortcut_name' removed successfully."
    else
        echo "Shortcut '$shortcut_name' does not exist in the controlled environment."
    fi
}

# Function to manage SSH commands
manage_ssh() {
    local action=$1
    local shortcut_name=$2
    local ssh_command

    case "$action" in
        add)
            if grep -q "^$shortcut_name:" "$SSH_CONFIG_FILE"; then
                echo "An SSH command already exists for $shortcut_name. Please remove it first."
                return
            fi
            ssh_command="${*:3}"  # Capture the entire SSH command as a single string
            echo "$shortcut_name:$ssh_command" >> "$SSH_CONFIG_FILE"
            echo "SSH command added for $shortcut_name."
            ;;
        remove)
            sed -i '' "/^$shortcut_name:/d" "$SSH_CONFIG_FILE"
            echo "SSH command removed for $shortcut_name."
            ;;
        execute)
            ssh_command=$(grep "^$shortcut_name:" "$SSH_CONFIG_FILE" | cut -d ':' -f 2-)
            if [[ -n "$ssh_command" ]]; then
                echo "Executing SSH command for $shortcut_name..."
                eval "$ssh_command"
            else
                echo "No SSH command found for $shortcut_name."
            fi
            ;;
    esac
}

# Function to export configuration
export_config() {
    local filename="$1"
    # Directly use the provided filename without altering the path
    # Check if the filename ends with .tar.gz, if not, append it.
    if [[ "$filename" != *.tar.gz ]]; then
        filename="${filename}.tar.gz"
        echo "Filename was updated to include the .tar.gz extension: $filename"
    fi

    # Ensure the directory for the export path exists or create it
    local export_dir=$(dirname "$filename")
    mkdir -p "$export_dir"

    # Adjust the tar command to correctly reference the paths of the files to be included
    # Assuming .switch_config, .switch_ssh_config, and the directory .switch_shortcuts are located directly in the user's home directory
    local config_path="${CONFIG_FILE#$HOME/}"  # Removes $HOME/ prefix from CONFIG_FILE path
    local ssh_config_path="${SSH_CONFIG_FILE#$HOME/}"  # Removes $HOME/ prefix from SSH_CONFIG_FILE path
    local shortcuts_dir="${SHORTCUT_DIR#$HOME/}"  # Removes $HOME/ prefix from SHORTCUT_DIR path

    # Create the tarball at the specified path
    tar -czf "$filename" -C "$HOME" "$config_path" "$ssh_config_path" "$shortcuts_dir"
    echo "Configuration and shortcuts exported to $filename"
}

# Function to import configuration including shortcuts
import_config() {
    local import_path="$1"
    if [[ ! -f "$import_path" ]]; then
        echo "The specified import file does not exist: $import_path"
        return
    fi

    echo "Backing up existing configurations..."
    local backup_dir="$HOME/.switch_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    if [[ -d "$SHORTCUT_DIR" ]]; then
        mv "$SHORTCUT_DIR" "$backup_dir/" && echo "Shortcuts backed up to $backup_dir"
    fi
    if [[ -f "$CONFIG_FILE" ]]; then
        mv "$CONFIG_FILE" "$backup_dir/" && echo "Config file backed up to $backup_dir"
    fi
    if [[ -f "$SSH_CONFIG_FILE" ]]; then
        mv "$SSH_CONFIG_FILE" "$backup_dir/" && echo "SSH config backed up to $backup_dir"
    fi

    echo "Importing configurations from $import_path..."
    if tar -xzf "$import_path" -C "$HOME"; then
        echo "Configuration and shortcuts imported successfully."
    else
        echo "Error importing configurations. Please check the import file and try again."
    fi
}

# Function to display_info 
display_info() {
    local current_shortcut_path=$(readlink "$SHORTCUT_DIR/current")
    local current_shortcut=""
    local max_desc_length=24  # Maximum length of the description
    local max_ssh_length=20   # Maximum length of the SSH command
    local format="%-16s | %-18s | %-22s | %-24s | %-20s\n"  # Adjusted widths for columns

    if [[ -n "$current_shortcut_path" && -f "$current_shortcut_path" ]]; then
        current_shortcut=$(basename "$current_shortcut_path")
    fi

    # Print the header
    printf "$format" "Shortcut" "Gmail User" "Project ID" "Description" "SSH Command"
    printf '%0.s-' {1..132}
    echo

    while IFS=':' read -r name account project description; do
        local ssh_command=""
        if grep -q "^$name:" "$SSH_CONFIG_FILE"; then
            ssh_command=$(grep "^$name:" "$SSH_CONFIG_FILE" | cut -d ':' -f 2)
        fi

        # Truncate the description if it's longer than the maximum length
        if [ "${#description}" -gt "$max_desc_length" ]; then
            description="${description:0:$max_desc_length-3}..."
        fi

        # Truncate the SSH command if it's longer than the maximum length
        if [ "${#ssh_command}" -gt "$max_ssh_length" ]; then
            ssh_command="${ssh_command:0:$max_ssh_length-3}..."
        fi

        # Remove @gmail.com from the email address
        account=${account%@gmail.com}
        
        local indicator="  "  # Two spaces by default
        if [[ "$name" == "$current_shortcut" ]]; then
            indicator="* "  # Asterisk with a space
        fi
        
        # Print the formatted line
        printf "$format" "$indicator$name" "$account" "$project" "$description" "$ssh_command"
    done < "$CONFIG_FILE"
}

# Function to execute a shortcut without automatically initiating SSH
execute_shortcut() {
    local shortcut_name=$1

    # Check for empty shortcut name
    if [[ -z "$shortcut_name" ]]; then
        echo "Please provide the name of the shortcut to execute."
        return
    fi

    # Execute the shortcut script
    if [[ -x "$SHORTCUT_DIR/$shortcut_name" ]]; then
        "$SHORTCUT_DIR/$shortcut_name"

        # Create/Update the symbolic link for the current shortcut
        ln -sf "$SHORTCUT_DIR/$shortcut_name" "$SHORTCUT_DIR/current"

        # Extract and print the description
        local description=$(grep "^$shortcut_name:" "$CONFIG_FILE" | cut -d ':' -f 4)
        if [[ ! -z "$description" ]]; then
            echo "Your setup is: $description"
        fi
    else
        echo "Shortcut '$shortcut_name' does not exist or is not executable."
    fi
}

# Function to get the current shortcut
get_current_shortcut() {
    local current_shortcut_path=$(readlink "$SHORTCUT_DIR/current")
    if [[ -n "$current_shortcut_path" && -f "$current_shortcut_path" ]]; then
        basename "$current_shortcut_path"
    else
        echo ""
    fi
}

# Main logic
case "$1" in
    add)
        current_shortcut=$(get_current_shortcut)
        if [[ -z "$current_shortcut" ]]; then
            echo "No active shortcut selected."
        else
            manage_ssh add "$current_shortcut" "${*:2}"
        fi
        ;;
    remove)
        current_shortcut=$(get_current_shortcut)
        if [[ -z "$current_shortcut" ]]; then
            echo "No active shortcut selected."
        else
            manage_ssh remove "$current_shortcut"
        fi
        ;;
    ssh)
        current_shortcut=$(get_current_shortcut)
        if [[ "$2" == "cmd" ]]; then
            # If 'cmd' is specified, show the command and wait for confirmation
            if [[ -z "$3" ]]; then
                # If no shortcut is specified, use the current shortcut
                if [[ -z "$current_shortcut" ]]; then
                    echo "No active shortcut selected."
                    exit 1
                fi
                ssh_command=$(grep "^$current_shortcut:" "$SSH_CONFIG_FILE" | cut -d ':' -f 2)
                echo "SSH Command for current shortcut '$current_shortcut':"
            else
                # If a specific shortcut name is provided
                ssh_command=$(grep "^$3:" "$SSH_CONFIG_FILE" | cut -d ':' -f 2)
                if [[ -z "$ssh_command" ]]; then
                    echo "No SSH command found for shortcut '$3'."
                    exit 1
                fi
                echo "SSH Command for '$3':"
            fi
            
            echo "$ssh_command"
            read -p "Press Enter to execute the command..."
            eval "$ssh_command"  # Execute the command
        else
            # Existing logic for executing SSH command
            if [[ ! -z "$2" ]]; then
                manage_ssh execute "$2"
            elif [[ ! -z "$current_shortcut" ]]; then
                manage_ssh execute "$current_shortcut"
            else
                echo "No active or specified shortcut to SSH into."
            fi
        fi
        ;;
    export)
        export_config "$2"
        ;;
    import)
        import_config "$2"
        ;;
    create)
        create_shortcut "$2"
        ;;
    update)
        update_shortcut "$2"
        ;;
    info)
        display_info
        ;;
    help)
        display_help
        ;;
    keygen)
        current_shortcut=$(get_current_shortcut)
        if [[ -z "$current_shortcut" ]]; then
            echo "No active shortcut selected."
            exit 1
        fi
        
        # Extract the SSH command for the current shortcut
        ssh_command=$(grep "^$current_shortcut:" "$SSH_CONFIG_FILE" | cut -d ':' -f 2)
        
        if [[ -z "$ssh_command" ]]; then
            echo "No SSH command found for the current shortcut."
            exit 1
        fi
        
        # Extract the IP address from the SSH command
        ip_address=$(echo "$ssh_command" | grep -o '@[^ ]*' | cut -d '@' -f 2)
        
        if [[ -z "$ip_address" ]]; then
            echo "No IP address found in the SSH command."
            exit 1
        fi
        
        # Run ssh-keygen -R [IPADDRESS]
        echo "Removing old host key for $ip_address..."
        ssh-keygen -R "$ip_address"
        echo "Old host key for $ip_address removed successfully."
        ;;
    *)
        # Existing logic for executing shortcuts
        if [[ "$2" == "ssh" ]]; then
            shortcut_name="$1"
            if [[ -z "$shortcut_name" || ! -f "$SHORTCUT_DIR/$shortcut_name" ]]; then
                echo "Shortcut '$shortcut_name' does not exist."
                exit 1
            fi
            execute_shortcut "$shortcut_name"
            manage_ssh execute "$shortcut_name"
        else
            execute_shortcut "$1"
            if [[ "$1" == "ssh" ]]; then
                current_shortcut=$(get_current_shortcut)
                if [[ -n "$current_shortcut" ]]; then
                    manage_ssh execute "$current_shortcut"
                else
                    echo "No active shortcut selected for SSH."
                fi
            fi
        fi
        ;;
esac
