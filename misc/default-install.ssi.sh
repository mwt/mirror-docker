#!/bin/sh
<!--#set var="repo_base_url" value="https://$host/$inc_foldername" -->
APP_NAME="<!--# echo var='inc_foldername' -->"
BASE_URL="<!--# echo var='repo_base_url' -->"
GPG_KEY="<!--# include file="./gpgkey" -->"

DEB_REPO="$BASE_URL/deb any main"
RPM_REPO="[$APP_NAME]
name=$APP_NAME
baseurl=$BASE_URL/rpm
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/$APP_NAME.asc"

<!--# include file="/internal/universal-install.sh" -->
