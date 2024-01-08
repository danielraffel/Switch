#!/bin/bash

# Directory for the shortcuts
SHORTCUT_DIR="$HOME/.switch_shortcuts"

# Path to store the configuration details
CONFIG_FILE="$HOME/.switch_config"

# Ensure the configuration file and shortcut directory exist
mkdir -p "$SHORTCUT_DIR"
touch "$CONFIG_FILE"

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
    echo "Switch - Google Cloud Configuration Management"
    echo "Usage: "
    echo "  switch create [name] - Create a new shortcut"
    echo "  switch update [name] - Update an existing shortcut"
    echo "  switch remove [name] - Remove an existing shortcut"
    echo "  switch info - Display information about all shortcuts"
    echo "  switch [name] - Activate the specified shortcut"
}

# Function to prompt for user input and confirm before continuing
prompt_for_input() {
    local input_var=$1
    local prompt_message=$2

    while true; do
        echo "$prompt_message"
        read "$input_var"
        echo "You entered: ${!input_var}"
        read -p "Is this correct? (yes/no): " confirmation
        case $confirmation in
            [Yy]* ) break;;
            [Nn]* ) echo "Please enter the correct information.";;
            * ) echo "Please answer 'yes' or 'no'.";;
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

# Function to update an existing shortcut
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

    # Extract current account and project
    current_account=$(grep "^$shortcut_name:" "$CONFIG_FILE" | cut -d ':' -f 2)
    current_project=$(grep "^$shortcut_name:" "$CONFIG_FILE" | cut -d ':' -f 3)

    # Request new description
    prompt_for_input new_description "Enter a new description for this setup: "

    # Update the configuration file
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

# Function to display information about all shortcuts
display_info() {
    echo "Configured Shortcuts:"
    while IFS=':' read -r name account project description; do
        echo "- $name: $account, $project, $description"
    done < "$CONFIG_FILE"
}

# Function to execute a shortcut
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

        # Extract and print the description
        local description=$(grep "^$shortcut_name:" "$CONFIG_FILE" | cut -d ':' -f 4)
        if [[ ! -z "$description" ]]; then
            echo "Your setup is: $description"
        fi
    else
        echo "Shortcut '$shortcut_name' does not exist or is not executable."
    fi
}

# Main logic
case "$1" in
    create)
        create_shortcut "$2"
        ;;
    update)
        update_shortcut "$2"
        ;;
    remove)
        remove_shortcut "$2"
        ;;
    info)
        display_info
        ;;
    help)
        display_help
        ;;
    *)
        execute_shortcut "$1"
        ;;
esac