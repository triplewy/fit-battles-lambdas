#!/bin/bash
folder_name=${1%/};
mkdir $folder_name
echo "Created $folder_name directory"
cd $folder_name || exit;
echo '/node_modules
.DS_Store
Archive.zip' > .gitignore
touch index.js
echo 'Created .gitignore and index.js'
yarn add mysql
echo 'Added mysql module'
