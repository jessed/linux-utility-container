# ~/.bash_functions
# My function list is getting too involved for .bash_aliases

# start the ssh-agent using whatever $SSH_AUTH_SOCK is defined
startagent() {
  if [[ -z "$SSH_AUTH_SOCK" ]]; then
    echo "ERROR: \$SSH_AUTH_SOCK not defined"
    return
  else
      KEYS="id_rsa cpt_shared.key"
    eval $(ssh-agent -a $SSH_AUTH_SOCK)
    if [ -n "$1" ]; then
      ssh-add $1
    else
      for k in $KEYS; do
        test -f ~/.ssh/${k} && ssh-add ~/.ssh/${k}
      done
    fi
  fi
}

# Update ssh environment info
update_ssh_env () {
  # If $SSH_AUTH_SOCK doesn't exist, clean up manual pid file
  if [[ ! -S ${SSH_AUTH_SOCK} && -n ${SSH_AGENT_PID+x} ]]; then
    rm ${TMPDIR}/ssh_agent_pid 2>/dev/null
    unset SSH_AGENT_PID
  elif [[ -z ${SSH_AGENT_PID+x} ]]; then
    # Add SSH_AGENT_PID environment var if not present
    test -f ${TMPDIR}ssh_agent_pid && export SSH_AGENT_PID=$(<${TMPDIR}ssh_agent_pid)
  fi
}

# Update $GOPATH if the current directory contains 'go_env' or .go_env
update_go () {
  if [[ -f go_env || -f .go_env ]]; then
    test -f go_env  && source go_env
    test -f .go_env && source .go_env
  else
    # if not in a Go dev directory, unset $GOPATH
    unset GOPATH
  fi
}

# check the hosts file for the string
# similar to 'host' but for the hosts file
hosts() {
  if [[ -z "$1" ]]; then echo -e "\tUSAGE:  $0 <hostname>"
  else myhost=$1
  fi

  grep -E $myhost /etc/hosts

  if [[ $? -ne 0 ]]; then
    echo "$myhost not found in /etc/hosts, checking with 'host'"
    host $myhost
  fi
}

watchhost() {
  go=1
  while [ $go -eq 1 ]; do
    ping -c1 -W 1 $1 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      #echo "ping succeeded, sleeping"
      sleep 1
    else
      #echo "ping failed, setting go = 0"
      echo "No echo response, entering notification phase"
      go=0
      sleep 1
    fi
  done

  while [ 1 ]; do
    ping -c1 $1 >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      sleep 1
    else
      echo -e "$1 is up\a"
      sleep 1
    fi
  done
}

# List all interfaces with addresses along with the address and mac
unset -f addr
addr() {
  match="(lo|gif|stf|pop|awdl|bridge|utun|fw|vnic)"

  #nics=$(ip link show | awk '/^[[:digit:]]/ {gsub(":"," "); print $2}')
  nics=$(ifconfig -a | awk '/^[a-z]/ { gsub(":[[:space:]]"," "); print $1}')

  for n in $nics; do
    declare -a addr
    if [[ $n =~ $match ]]; then continue
    else iface=$n
    fi

    if [[ -f /etc/issue ]]; then
      # linux
      mac=$(ip addr show $iface | awk '/ether/{ print $2 }')
      addr+=($(ip addr show $iface | awk '/inet /{ print $2 }'))
    else
      # mac
      info=$(ifconfig $iface)
      mac=$(echo "$info" | awk '/ether / { print $2}')
      addr+=$(echo "$info" | awk '/inet / { print $2}')
    fi

    # Only print the interface name if the first address is populated
    if [[ -n "${addr[0]}" ]]; then
      s="${iface}"
      iPad=$(expr 10 - $(echo -n "${s}" | wc -c))
      printf "%-${iPad}s" ${s}
    fi
    # calculate the length of padding to use for the first address output
    # I want a consistent column depth while still having the first address on the same line
    # as the interface id
    aPad=20
    for a in ${addr[@]} ; do
      mPad=$(expr 25 - $(echo -n ${a} | wc -c))
      m="(${mac})"
      printf "%${iPad}s %-${aPad}s %-${mPad}s\n" " " $a $m
      iPad=10
    done
    unset -v iface info addr mac
  done
}

# List all interfaces and addresses using the 'ip' command
unset addr2
addr2() {
  ip -4 -o addr show | awk '{print $2"\t"$4}'
}

# source environment files more intelligently
src() {
  if [[ -n "$1" ]]; then
    LIST=$1
  else
    LIST="$LIST .bash_aliases .bash_functions .bash_local"
    LIST="$LIST local/remote_systems.bash"
    LIST="$LIST local/DUT_consoles.bash"
    LIST="$LIST local/DUT_mgmt.bash"
    LIST="$LIST ltm_helpers/ltm_functions.bash"
  fi

  for f in $LIST; do
    test -f ${HOME}/${f} && { echo "Sourcing ${HOME}/${f}"; source ${HOME}/${f}; }
  done
}

# redefine 'exit' to be screen-friendly (new method, compatible with OS X)
exit() {
  if [[ -n "$WINDOW" ]]; then
    screen -p $WINDOW -X pow_detach
  else
    kill -1 $$
  fi
}


# count the characters in the string
count() {
  if [ -z "$1" ]; then echo "Must provide a string"; return; fi

  string=$1
  echo -n "$string" | wc -c
}

reminder() {
  if [ -z "$1" ]; then
    timer=180
  else
    if [ $1 -lt 60 ]; then
      timer=$((1*60))
    else
      timer=$1
    fi
  fi

  echo "Reminder will occur in $timer seconds"
  sleep $timer

  while [ 1 ]; do
    echo -e "\a"
    sleep 1
  done
}


clrlog() {
  if [[ -z "$1" ]]; then
    echo "USAGE: $0 <log file>"; exit 1
  else
    file=$1
  fi

  rm $file
  sudo service syslog-ng restart
}

##
## Linux-specific
##

# Add nginx yum repository
add_nginx_centos() {
  cat > nginx.repo << EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
EOF

  sudo mv nginx.repo /etc/yum.repos.d
  sudo yum update -y
  sudo yum install -y nginx
  sudo systemctl enable nginx
  sudo systemctl start nginx
}


# vim: set syntax=sh tabstop=2 expandtab:
