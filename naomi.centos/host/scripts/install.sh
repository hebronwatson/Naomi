# Author: Hebron Watson
# Purpose: Install 1CRM application and dependencies
# Date: December 20, 2018

# GLOBALS
FILE_SEP='/'

# test de function
DEBUG=true
DATE="$(date '+%Y-%m-%d %H:%M:%S')"
LOGFILE="/var/log/vagrant_install_log"
echo "VAGRANT_INSTALL_SCRIPT_RUN: $DATE" | tee $LOGFILE;
echo "-------------------------------------------------------------------------------------------------------------" | tee $LOGFILE;
function de(){
  if [[ $DEBUG ]]
  then
    echo $1 | tee -a $LOGFILE;
  else
    echo $1 >> $LOGFILE;
  fi
}

# endscript function
function endscript(){
  if [[ -z $1 ]]
  then
    EXIT_NUM=1
  else
    EXIT_NUM=$1
  fi

  de "--- *end-of-run* ---"
  de "-------------------------------------------------------------------------------"
  exit $EXIT_NUM;
}

# Function for changing settings in property files
function setConfigProperty(){
  PROPERTY="$1";
  SETTING="$2";
  FILEPATH="$3";
  # optional environment variable
  if [[ ! -z "$SET_CONFIG_PROPERTY_FILEPATH" ]]
  then
    FILEPATH="$SET_CONFIG_PROPERTY_FILEPATH";
  fi

  # test for file existence
  if [[ ! -f "$FILEPATH" ]]
  then
    echo "Source File Does Not Exist: ($FILEPATH)";
    return 0;
  else
    # -- [^=]* -- captures on any number of elements that are NOT '='                             < === f
    # -- [^=]*= -- captures that plus "= "                                                        < === f'
    # -- [^=]*= .* -- captures that plus anything else that comes until the end of the line       < === f''
    if [[ $(sed -ibak -r "s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)/\1\2$SETTING/g" "$FILEPATH") ]] 
    then
      de "Set configuration setting for $LABEL_NAME to $SETTING";
      return 1;
    else
      de "Could not find configuration setting for $LABEL_NAME; nothing changed";
      return 0;
    fi
  fi 
}

# set root password for later mysql use:
echo -e 

# Variable for temporary directory
TMP_DIR="/tmp/"
TMP_FILE="yum_installed"
# concatenated path and filename with file seperator ( '/' on unix, '\' on windows )
tf="${TMP_DIR}${FILE_SEP}${TMP_FILE}"
# test deing
de "Temperary Directory: $TMP_DIR"
de "Temporary Filename: $TMP_FILE"
de "Temporary File Path: $tf"
de "Now configuring..."
# make a temporary directory if it is not already available
if [ ! -d "$TMP_DIR" ]
then
  mkdir "$TMP_DIR"
fi # endif -- temp dir

# make fresh list of installed programs
# https://www.howtoforge.com/community/threads/de-into-a-file.115/
yum list installed | sed '1d' | tee "$tf"

if [[ $(grep -E php7[1w]? "$tf") ]]
then
  de "PHP7 and MariaDB are installed on the system..."
  de "Proceeding until missing package is found..."
else
  de "Downloading requisite packages..."
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
  yum -y install \
  bash-completion wget unzip nano vim tree \
  httpd.x86_64 \
  nodejs \
  mod_php71w php71w-cli php71w-common php71w-gd php71w-mbstring.x86_64 php71w-mcrypt php71w-mysqlnd \
	php71w-xml php71w-imap php71w-pear.noarch php71w-soap php71w-pecl-apcu php71w-opcache \
  mariadb-server.x86_64 \
  policycoreutils-python
	

  # installing git capable of work tree
  de "Installing git capable of worktree"
  if [[ $(yum -y install http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm) && \
    $(yum -y remove git) && $(yum -y install git) ]]
  then
    de "successfully installed version of Git capable of using worktree"
  else
    de "installing regular Git"
    yum -y install git
  fi

  de "configuring running services"
  systemctl enable httpd 
  systemctl start httpd
  systemctl enable mariadb
  systemctl start mariadb
  echo '<?php phpinfo(); ?>' > /var/www/html/info.php
fi


####################################################################3
# in /etc/php.ini
#  set output_buffering=On
# Here's a working example for matching all parts of a similar statement for unix style properties in text files:
  # sed -rn 's/(^output_buffering)([^=]*= )([\w\d]*)()()()()()()()()()()()()()()()()()()()()()/NINE:\9EIGHT:\8SEVEN:\7SIX:\6FIVE:\5FOUR:\4THREE:\3TWO:\2ONE:\1GO:WEEEEEEEEEEE!$/p' </etc/php.ini

# Value being changed
LABEL_NAME="output_buffering"
# New Value
SETTING="On"
# File to pull from
# currently working with php settings in .ini file
PHP_INI="/etc/php.ini"
# SED COMMAND
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()/\1\2$SETTING/g"

# logging
de "LABEL_NAME = $LABEL_NAME";
de "SETTING = $SETTING";
de "PHP_INI = $PHP_INI";
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" "$PHP_INI"
# setConfigProperty "$LABEL_NAME" "$SETTING" "$PHP_INI";
#  set zlib.output_compression=Off
LABEL_NAME="zlib\.output_compression"
SETTING="Off"
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" "$PHP_INI"
#  set max_execution_time=300
LABEL_NAME="max_execution_time"
SETTING="300"
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" "$PHP_INI"
#  set max_input_time=300
LABEL_NAME="max_input_time"
SETTING="300"
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" "$PHP_INI"
#  set memory_limit=200M
LABEL_NAME="memory_limit"
SETTING="200M"
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" "$PHP_INI"
#  set display_errors=Off
LABEL_NAME="display_errors"
SETTING="Off"
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" "$PHP_INI"
#  set post_max_size=25M
LABEL_NAME="post_max_size"
SETTING="25M"
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" "$PHP_INI"
#  set upload_max_filesize=22M
LABEL_NAME="upload_max_filesize"
SETTING="22M"
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" "$PHP_INI"
#  set mysql.default_socket=
LABEL_NAME="mysql\.default_socket"
SETTING=""
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" "$PHP_INI"
#  set session.gc_maxlifetime=3600
LABEL_NAME="session\.gc_maxlifetime"
SETTING="3600"
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" "$PHP_INI"
#  set session.save_path=/var/lib/php/session
LABEL_NAME="session\.save_path"
SETTING="\/var\/lib\/php\/session"
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" "$PHP_INI"
#################################################################
chgrp apache /var/lib/php/session
chmod g+rwX /var/lib/php/session
#change apc.serializer in apcu.ini
LABEL_NAME="apc\.serializer"
SETTING="\'php\'"
SED_COMMAND="s/(^$LABEL_NAME)([^=]*=[ ]*)(.*)()()()()()()()()()()()()()()()()()()()()()/\1\2$SETTING/g"
de "SED COMMAND = $SED_COMMAND";
sed -ibak -r "$SED_COMMAND" /etc/php.d/apcu.ini

# TODO install gpg key for git clone
GIT_SSH_KEYFILE="/home/vagrant/.ssh/id_rsa";
VAGRANT_GUEST_SSH_STORE="/home/vagrant/.ssh"
VAGRANT_HOST_SSH_STORE="/host/_ssh"
GIT_SSH_KEY_PROVIDED=1;
GIT_REPO_URL="git@bitbucket.org:hebronwatson/hoopscore.git"
HOST_FINGERPRINT="bitbucket.org ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAubiN81eDcafrgMeLzaFPsw2kNvEcqTKl/VqLat/MaB33pZy0y3rJZtnqwR2qOOvbwKZYKiEO1O6VqNEBxKvJJelCq0dTXWT5pbO2gDXC6h6QDXCaHo6pOHGPUy+YBaGQRGuSusMEASYiWunYN0vCAI8QaXnWMXNMdFP3jHAJH0eDsoiGnLPBlBp4TNm6rYI74nMzgz3B9IikW4WVK+dc8KZJZWYjAuORU3jc1c/NPskD2ASinf8v3xnfXeukU0sJ5N6m5E8VLjObPEO+mN2t/FZTMZLiFqPWc/ALSqnMnnhwrNi2rbfg/rd/IpL8Le3pSBne8+seeFVBoGqzHM9yXw==";
REPO_DIR="hoopscore"
HOME_DIR="/home/vagrant";
URL="";
INSTANCE="";
ZIP_FILEPATH="${HOME_DIR}${FILE_SEP}${INSTANCE}\.zip";
APACHE_ROOT="/var/www/html"
INSTANCE_ROOT="${APACHE_ROOT}${FILE_SEP}${INSTANCE}"

# determine whether ssh key is present
if [[ ( $GIT_SSH_KEY_PROVIDED -eq 1 ) ]]
then
  if [[ ! -f "$GIT_SSH_KEYFILE" ]]
  then
    cp -R "$VAGRANT_HOST_SSH_STORE" "$VAGRANT_GUEST_SSH_STORE"
  fi
  # manage file permissions on ssh keys
  chown -R vagrant /home/vagrant/.ssh
  chmod -R 600 /home/vagrant/.ssh 
  chmod 700 /home/vagrant/.ssh
  # configs the ssh agent
  # ssh agent cannot run without the configuration information emitted by the 'ssh-agent' command being run in the shell
  eval "$(ssh-agent)"
  # add the ssh key to the ssh agent so it can be used in communication with Git
  # requires that keyfile has no passphrase
  ssh-add "$GIT_SSH_KEYFILE"
  # TODO: pull from Git
  cd /var/www/html
  # add host fingerprint for automatic access to repo
  echo "$HOST_FINGERPRINT" >> "/home/vagrant/.ssh/known_hosts"
  git clone "$GIT_REPO_URL"
  # SE Linux management

else
  # If configured to download and extract a package, then do so...
  if [[ ( ! -z "$URL" ) && ( ! -z "$INSTANCE" ) ]]
  then
    if [[ ( ! -f "$ZIP_FILEPATH" ) ]]
    then
      # zip package not downloaded
      curl -o "$ZIP_FILEPATH" "$URL";
    fi
    if [[ ( ! -d "$INSTANCE_ROOT" ) ]]
    then
      de "Extracting 1CRM Startup Edition .zip file into web server..."
      unzip -d "$INSTANCE_ROOT" "$ZIP_FILEPATH" | tee -a "$LOGFILE"
    fi
  fi
fi
# manage file permissions 
chown -R vagrant "/var/www/"
chgrp -R apache "$INSTANCE_ROOT"
chmod -R g+rwX "$INSTANCE_ROOT"
# manage SE Linux settings pertaining to these directories
# semanage fcontext -a -t httpd_sys_content_t "${INSTANCE_ROOT}(/.*)?"
semanage	fcontext -a -t httpd_sys_rw_content_t	"${APACHE_ROOT}(/.*)?"
# restorecon
restorecon -Rv "$INSTANCE_ROOT" | tee -a "$LOGFILE"
# hopefully we will not need this
setenforce permissive
# done
endscript 0;
# selinux