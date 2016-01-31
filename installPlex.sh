echo "If you have a PlexPass this script can automatically download and install the latest PlexPass Plex Server build."
read -p "Do you have a PlexPass?? " answer
    case ${answer:0:1} in y|Y )
        echo "Please enter your Plex username or email address: "
        read plexusername
        echo "Please enter your Plex password: "
        read plexpassword; break;;
    ;;
    * )
        echo No
    ;;
esac
