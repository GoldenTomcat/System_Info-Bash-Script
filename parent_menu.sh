
#!/bin/bash
#The above line tells the Operating System that the file to be executed is a bash file and to use a bash interpreter to run the script
#The line specfies that this is a bash shell, along with the location of the binaries for the Bash shell

# This variable stores the value for dialog's exit code for the cancel option
RETURN=1


# Function defined for the display of date/time menu when
date_time() {
	dialog --title "$1" --msgbox "$cmd" 0 0
}

# Function for showing calendar notes
show_calendar_notes() {
	dialog --title "$1" --msgbox "$cmd" 0 0


}

# Function for showing the calendar and taking in notes
show_calendar() {
	#EXEC replaces the current running processes. 3
	#EXEC replaces the current running process with a new process.
# The 3 and 1 in 3>&1 are file descriptors for the I/O streams. There are 3 types of I/O stream(resulting in 3 base file descriptors):: 0 - Stdin(this is your input, your keyboard)-
# 1 - Stdout(this is your output, your screen) and 2 - Stderr (diagnostic output, error messages)
# The numbers (0,1,2) are file handles that the running process uses to gather input(stdin0), write output(stdout1) and write diagnostic output(stdout2) respectively.
# What is happening below is: Replace the current process (3 is our script's file descriptor) and redirects the new process into stdout(1).
#(SideNote: > represents output redirection and < represents input redirection)
	exec 3>&1
	# This line works in two parts. First it creates the calendar and asigns it to the variable. Whenever a user picks a date in the calendar that date will be sent to this variable
	# $1 is defined as the argument in the function and used for the title
	# The first two 0s denote default width and height for the dialog
	# && is logical  AND and is used to immediately run the second command for an input box for writing notes
	# 2>&1 is used to redirrect stderr to stdout to allow for the selected options to return value and 1>&3 is used to send stdout to our script so we can see these boxes
	DATE_PICKED=$(dialog --title "$1" --calendar "Select a day to input a note!" 0 0 0 0 0 2>&1 1>&3) && notes=$(dialog --inputbox "Enter your notes" 10 50 2>&1 1>&3)
	# Variable created that stores an exit code from dialog. 0 is ok and 1 is cancel
	exiting=$?
	# case statement functions like an if statement. if the value of exiting is like the return variable (1) then run the function called main which returns you to the main menu
	case $exiting in
		$RETURN)
			main
		;;
	esac
	# Initialize a dictionary for storing the date along with its accompanying note
	declare -A notes_array
	# define the array. Set the key to be the date and the value to be the note
	notes_array=( [ "$DATE_PICKED" ]="$notes")
	# Iterate over the array and add each date along with it's assigned note
	for i in "${!notes_array[@]}"; do printf "[%s]=%s\n" "$i" "${notes_array[$i]}" >> notes.txt ;done
	#printf %s\n ${notes_array[@]} > notes.txt#
	# close file descriptor 3 and stdout for writing
	exec 3>&-
	# recursively call the show calendar function again so that you aren't booted to menu after you select a date+note
	show_calendar 'your calendar'
}

# Function for the directory search/delete
directory_search_delete() {
	# Replace running process with a new process which redirects file descriptor 3 to stdout for our output
	exec 3>&1
	# Creates the file selection menu dialog and assigns any choices made in it to a variable
	# Additionally creates a dialog to confirm whether you want to delete the chosen file
	# 2>&1 is used to redirrect stderr to stdout to allow for the selected options to return value and 1>&3 is used to send stdout to our script so we can see these boxes
	mark_delete=$(dialog --no-cancel --fselect "$1" 0 0 2>&1 1>&3) && confirm=$(dialog --yesno "Are you sure you want to delete?" 0 0 2>&1 1>&3)
	# Stores the exit code (0 for ok 1 for cancel) from the confirmation prompt
	confirm=$?
	# If/Else statement for if yes is picked then remove the file and output diagnostics where neccesary
	if [ $confirm == 0 ];
	then
		# Runs the rm command and removes the choses file and stores this action as a variable
		cmd=$(rm "$mark_delete")
		# Make a dialog box which contains the diagnostics if present or an empty box if not
		dialog --msgbox "$cmd" 0 0
	# If no was selected then go back the previous menu which will put you in the directory you were previously
	else
		directory_search_delete $path
	fi
	# Close file descriptor 3 and stdout for writing
	exec 3>&-
}

# Below are the definitions for the entire main menu
main() {

# While True loop set to keep the menu running whilst open
while true; do

#EXEC replaces the contents of the running process with a new process.
# The 3 and 1 in 3>&1 are file descriptors for the I/O streams. There are 3 types of I/O stream(resulting in 3 file descriptors):: 0 - Stdin(this is your input, your keyboard)-
# 1 - Stdout(this is your output, your screen) and 2 - Stderr (diagnostic output, error messages)
# The numbers (0,1,2) are file handles that the running process uses to gather input(stdin0), write output(stdout1) and write diagnostic output(stdout2) respectively.
# What is happening below is: While True: create a new process and takes our script (3 is our script) and redirects it to stdout(1).
#(SideNote: > represents output redirection and < represents input redirection)
	exec 3>&1
	# create a variable as a command to start dialog with the defined options and defined dimensions of the menu box.--no-cancel removes the defualt cancel box.
	# output is redirected at the end of the dialog command with stderr being output to stdout and redirecting stdout to our script (3) so we can get our dialog displayed
	init_menu=$(dialog --title "Administrative Functions" --no-cancel --menu "Select an operation:" 0 0 5 "1:" "Date/time" "2:" "Calendar" "2b:" "View Calendar Notes" \
	"3:" "Delete" "4:" "System Configuration" \
	"5:" "Exit" 2>&1 1>&3 )
	# Close file descriptor 3 and stdout for writing
	exec 3>&-
	# Case statement for choosing one of the 5 menu options
	case $init_menu in
		# Choice 1 runs the Date/Time function
		1: )
			# Prepares the output for the datetime box using the unix date comannd
			cmd=$(echo "Date/Time: $DATE"; date)
			# Calls the date/time function with the title of the upcoming dialog box as an argument 
			date_time 'system date&time information'
			;;
		# Choice 2 runs the calendar function
		2: )	
			# Calls the calendar function with the title of the upcoming dialog box as an argument
			show_calendar 'Your Calendar'
			;;
		# Auxiliary choice for choice 2 allowing calendar notes to be viewed
		2b: )
			# Prepares the output for the calendar notes using the unix cat command to display the contents of the file storing the notes in the upcoming-
			# dialog box
			cmd=$(cat notes.txt)
			# Call the Calendar Notes function with the title passed as an argument
			show_calendar_notes 'Calendar Notes'
			;;
		# Choice3 runs the file select function
		3: )
			# substitutes the running process for a new one and redirrects file descriptor 3 to stdout so we can see our output
			exec 3>&1
			# Creates a dialog asking user to provide a directory
			# Redirects stderr to stdout and stdout to descriptor 3
			path=$(dialog --inputbox "Provide a directory" 10 50 2>&1 1>&3 )
				if [ $path == "" ];
				then 
					# If the user does not provide a directory then the script will use the current directory
					# Current directory is gathered from the print-working-directory command and stored as path
					path=$(pwd)
				fi
			# Close file descriptor 3 for writing
			exec 3>&-
			# call the directory search function with the display showing the path the user provided moments ago as an argument
			directory_search_delete $path
			
			;;
		# Choice 4 runs the child menu
		4: )
			# forks the process from the parent menu and runs the child menu as a child process
			 ./child_menu.sh 
			;;
		5: )
			# Clear the screen, print bye bye and terminate the running script
			clear
			echo "Bye bye!"
			exit
			;;
	# Finish the case statement for main menu selection
	esac
# Finish the while loop
done

}
# Run the main function
main
