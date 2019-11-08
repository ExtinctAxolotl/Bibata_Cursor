#!/bin/bash
#
#Bibata Build
#
#Released under the GNU General Public License, version 3.
#Author : KAiZ
#

echo -e "\n"
echo -e " ██████╗ ██╗██████╗  █████╗ ████████╗ █████╗   "
echo -e " ██╔══██╗██║██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗ "
echo -e " ██████╔╝██║██████╔╝███████║   ██║   ███████║  "
echo -e " ██╔══██╗██║██╔══██╗██╔══██║   ██║   ██╔══██║  "
echo -e " ██████╔╝██║██████╔╝██║  ██║   ██║   ██║  ██║  "
echo -e " ╚═════╝ ╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝  "
echo -e "\n"

#functions
#Color print function 
show_Msg() {
    echo -e "\033[1;37m$@\033[0m"
}
show_pre(){
    echo -ne "\033[1;33m$@\033[0m"
}
show(){
    echo -e "\033[1;32m$@\033[0m"
}
selection(){
    echo -e "\033[1;36m$@\033[0m"
}
error(){
    echo -e "\033[1;31m$@\033[0m"
}

selectWithDefault() {

    local item i=0 numItems=$# 

    # Print numbered menu items, based on the arguments passed.
    for item; do         # Short for: for item in "$@"; do
    printf '%s\n' "$((++i))) $item"
    done >&2 # Print to stderr, as `select` does.

    # Prompt the user for the index of the desired item.
    while :; do
    printf %s "${PS3-#? }" >&2 # Print the prompt string to stderr, as `select` does.
    read -r index
    # Make sure that the input is either empty or that a valid index was entered.
    [[ -z $index ]] && break  # empty input
    (( index >= 1 && index <= numItems )) 2>/dev/null || { echo "Invalid selection. Please try again." >&2; continue; }
    break
    done

    # Output the selected item, if any.
    [[ -n $index ]] && printf %s "${@: index:1}"

}

build(){
    #get name of theme by argument 
    cursor=$1

    #building cursor with python script
    show_pre "\n$cursor : Generating bitmaps...\\r"

    # if cursors source folder & file doesn't exist
    if [ ! "src/$cursor/source-cursors.svg" ]; 
    then
        error "\n$cursor : Source not found"
        error "\nAborting..."
        exit 1
    else
        #-o for genrating hotspots
        #-a for genrating config files
        python render-cursors.py ./src/$cursor/source-cursors.svg -o -a --name $cursor
        # $? =  is the exit status of the most recently-executed command; by convention, 0 means success and anything else indicates failure. 
        if [ $? -eq 0 ]
        then
            show "$cursor : Generating bitmaps... DONE"
        else
            error "$cursor : Generating bitmaps... FAIL"
            error "\nAborting..."
            exit 1
        fi

        show_pre "\n$cursor : Building X11 cursor...\\r"
        #execute x11-make.sh file with theme_name argument
        sh x11-make.sh "$cursor"
        #Copy .index files to out/$cursor
        cp src/"$cursor"/*.theme "$cursor"/out/X11/"$cursor"
        if [ $? -eq 0 ]
        then
            show "$cursor : Building X11 cursor... DONE"
            echo "OUT: $PWD/$cursor/out/X11"
        else
            error "$cursor : Building X11 cursor... FAIL"
            error "\nAborting..."
            exit 1
        fi

        show_pre "\n$cursor : Building Window cursor...\\r"
        #execute x11-make.sh file with theme_name argument
        sh w32-make.sh "$cursor"
        if [ $? -eq 0 ]
        then
            show "$cursor : Building Window cursor... DONE"
            echo "OUT: $PWD/$cursor/out/win"
        else
            error "$cursor : Building Window cursor... FAIL"
            error "\nAborting..."
            exit 1
        fi
    fi
    
}

#main program

#Requirment checking
show_pre "Checking Requirements...\\r"

if  ! type "inkscape" > /dev/null ; then
    error "\\nFAIL: inkscape must be installed"
    exit 1
fi

if  ! type "xcursorgen" > /dev/null ; then
    error "\\nFAIL: xcursorgen must be installed"
    exit 1
fi

if ! command -v python3 &>/dev/null; then
    error "\\nFAIL: python3 must be installed"
    exit 1
fi

if ! command pip &>/dev/null; then
    error "\\nFAIL: pip must be installed"
    exit 1
fi
show "Checking Requirements... DONE"

#Install pip requirments
show_pre "Installing PiP Requirements...\\r"

if [ ! "requirements.txt" ]; 
    then
        error "\n$cursor : requirements.txt not found"
        error "\nAborting..."
        exit 1
else
    pip3 install -r requirements.txt --user 
fi

if [ $? -eq 0 ]
then
    show "Installing PiP Requirements... DONE"
else
    error "Installing PiP Requirements... FAIL"
    error "\nAborting..."
    exit 1
fi


#choice for build cursor
selection "Cursor to build (Default is 'ALL')?"
cursors=("Bibata Oil" "Bibata Ice" "Bibata Amber" "test" "ALL"  exit )
cursor=$(selectWithDefault "${cursors[@]}")

# Process the selected item.
case $cursor in
  (''|'ALL') echo "ALL"; ;;
  ('Bibata Oil') build "$cursor"; ;;
  ('Bibata Ice') build "$cursor"; ;;
  ('Bibata Amber') build "$cursor"; ;;
  ('test') build "$cursor"; ;;
esac

show_pre "Generating Installer...\\r"

if [ "src/in.inst" ]; then
	cp src/in.inst Bibata.sh
fi

if [ $? -eq 0 ]
then
    show "Generating Installer... DONE"
else
    error "Generating Installer... FAIL"
    error "\nAborting..."
    exit 1
fi

show_pre "Making Installer Executable...\n"

if [ "Bibata.sh" ]; then
	sudo chmod +x Bibata.sh
fi

if [ $? -eq 0 ]
then
    show "Making Installer Executable... DONE"
    show_Msg "For Installation Use Following Command:\n"
    show_Msg "\t sudo ./Bibata.sh\n\t\tOR\n\t./Bibata.sh"
else
    error "Making Installer Executable... FAIL"
    error "\nAborting..."
    exit 1
fi

show_Msg "\n🎉 BUILD COMPLETE! 🎉"
