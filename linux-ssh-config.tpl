cat << EOF >> ~/.aws/config

Host ${hostname}
    Hostname ${hostname}
    User ${user}
    IdentifyFile ${identifyFile}
EOF

