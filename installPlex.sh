echo "If you have a PlexPass this script can automatically download and install the latest PlexPass Plex Server build."
echo "Do you have a PlexPass?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
            echo "Please enter your Plex username or email address: "
            read plexusername
            echo "Please enter your Plex password: "
            read plexpassword; break;;
        No )
            exit;;
    esac
done
