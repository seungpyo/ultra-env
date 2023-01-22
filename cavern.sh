flag_file=".gcloud.lock"
if [ ! -e "$flag_file" ]; then
    gcloud init
    gcloud auth application-default login
    echo "Command executed"
    touch "$flag_file"
fi