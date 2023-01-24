#!/bin/bash
# The line tells the terminal interpreter that this script is to be executed using a bash shell

# A variable to store the value of dialog's exit code for the yes/ok option
RETURN=1

# Make a function for the message boxes 
msg_boxes() {
	# Displays a message box with a title that is passed to the function as an arg and the contents are also passed as args
	# 0 0 denoted default width and height for the box
	dialog --title "$1" --msgbox "$cmd" 0 0
}

# While loop that keeps the menu open whilst it's being looked at
while true; do
	# Substitues the running process for a new process and redirectes file decriptor 3 to stdout allowing us to see the following menus
	exec 3>&1
	# main menu created instead the variable. User choice of submenu is stored within this variable
	# 2>&1 1>&3 is redirecting stderr to stdout and stdout to descriptor 3
	root_menu=$(dialog --title "System Information" --cancel-label "Return" --menu "Select an option:" 0 0 5 "1:" "Operating System Type" "2:" "CPU information" "3:" "Memory Information" \
	"4:" "Hard Disk Informtion" "5:" "File System (Mounted)" 2>&1 1>&3 )
	# Stores the reply of the user when they choose either ok or return
	exiting=$?
	# Close file descriptor 3 for writing
	exec 3>&-
	
	# Case statement where if exit choice is return (exit code 1) then:
	case $exiting in
		$RETURN)
			# Use pgrep to find the process IDs of the child process an store them in a variable
			PIDs=$(pgrep -f child_menu.sh)
			# use signal 15 (SIGTERM) to cleanly terminate the child processes and exit the script
			kill -15 $PIDs
			;;
	esac
	
	# Case statements for choosing the submenus
	case $root_menu in
		# Choice 1 displays the OS and Host info
		1: )
			# Run and display the hostnamectl command which diplays the OS info. Store this as a variable to be displayed in the message box
			cmd=$(echo "OS and Host Info: $HOSTNAMECTL"; hostnamectl)
			# call the message box function with the title passed as an argument
			msg_boxes 'Operating System info'
			;;
		# Choice 2 displays the CPU info
		2: )
			# Run and display the CPU info using the lscpu command
			# Using | pipes the lscpu command into the head command which then outputs the first 24 lines of the lscpu command
			cmd=$(echo "CPU Information: $LSCPU"; lscpu | head -24)
			# Call the message box function with the title passed as an argument
			msg_boxes 'CPU Info'
			;;
		# Choice 3 displays the memory info
		3: )
			# Read and display the first 15 lines of the memory info file
			cmd=$(echo "Memory Information: $HEAD"; head -15 /proc/meminfo)
			# Call the message box function with the title passed as an argument
			msg_boxes 'Memory Info'
			;;
		# Choice 4 Displays the Hard Disk info
		4: )	# redirect  descriptor 3 to stdout for our output
			exec 3>&1
			# Take user sudo password
			# redirect stderr to stdout and stdout to descriptor 3
			passwd=$(dialog --passwordbox "Enter super-user password" 10 50 2>&1 1>&3 )
			# run and display df for disk info and pipe the password argument into sudo for sudo df
			cmd=$(echo "Hard Disk Info: $DF"; echo $passwd | sudo -S df)
			# close descriptor 3 for writing
			exec 3>&-
			# Call the message box function with the title passed as an argument
			msg_boxes 'Disk Info'
			;;
		# Choice 5 for the mounted file systems
		5: )
			# Run findmnt and display the mounted filesystems
			cmd=$(echo "Currently Mounted FilesSystems: $FINDMNT"; findmnt)
			#  Call the message box function with the title passed as an argument
			msg_boxes 'Mounted FileSystems'
			;;
	# case statements end
	esac
# While loop ends
done
