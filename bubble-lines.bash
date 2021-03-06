#
## about:A cool and bubbly Bash prompt
#

#●─[victor]─[~/.bash-config/themes]─[⏻ 80%]─[ⵌ]─[master  ✚87]─●
#|    |                 |              |      |         |- Git status
#|    |                 |              |      |- sudo cached
#|    |                 |              |- Battery status
#|    |                 |- CWD
#|    |- Username
#|- Exit code

## User choices
battery_info="y"
sudo_info="y"

# Choose from: ⌚, ⏳, ✰, ⵌ, ✷
sudo_icon="ⵌ"

# For online status, make sure to copy the file to your home folder
# and add the line below to cron
# * * * * * /bin/bash ~/.online-check.sh
online_status="n"

# Reset
PS_Color_Off='\[\e[0m\]'

# Regular Colors
PS_Black='\[\e[30m\]'
PS_Red='\[\e[31m\]'
PS_Green='\[\e[32m\]'
PS_Yellow='\[\e[33m\]'
PS_Blue='\[\e[34m\]'
PS_Purple='\[\e[35m\]'
PS_Cyan='\[\e[36m\]'
PS_White='\[\e[37m\]'

Func_Green='\001\e[0;32m\002'
Func_Blue='\001\e[0;34m\002'
Func_Yellow='\001\e[0;33m\002'
Func_Purple='\001\e[0;35m\002'
Func_Red='\001\e[0;31m\002'
Func_Color_Off='\001\e[0m\002'

_sudo_status () {
  sudo -n uptime 2>&1 | grep -q "load"
  if [[ $? -eq 0 ]] ; then
    echo -e "─[${Func_Yellow}$sudo_icon${Func_Color_Off}]"
  fi
}

_git_branch () 
{
  local gitbranch gitstatus modified

  gitbranch=$(git branch 2> /dev/null | grep '\*' | sed -e 's/* \(.*\)/\1/')

  if [ "$gitbranch" ] ; then
    gitbranch="${gitbranch} "
    gitstatus=$(git status -s)
    modified="✚$(git status -s | wc -l)"

    if [ "$gitstatus" ] ; then
      printf "─[${Func_Purple}${gitbranch} ${modified}${Func_Color_Off}]"
    else
      printf "─[${Func_Green}${gitbranch} ✔${Func_Color_Off}]"
    fi
  fi
}

_get_battery_info () {
  local ac_adapter_disconnected

  ac_adapter_info="$(upower -i $(upower -e | grep BAT) |  egrep '(state|percentage)')"
  ac_adapter_disconnected=$(echo "$ac_adapter_info" | grep 'state' | grep -q 'discharging' ; echo $?)
  ac_adapter_connected=$(echo "$ac_adapter_info" | grep 'state' | grep -q 'charging' ; echo $?)

  if (( ac_adapter_disconnected == 0 )) ; then
    battery_percentage="$(echo "$ac_adapter_info" | grep percentage | grep -o "[0-9]\+")"
    battery_icon="⏻ "
    if (( battery_percentage > 70 )) ; then
      echo -e "─[${Func_Green}${battery_icon}${battery_percentage}%${Func_Color_Off}]"
    elif (( battery_percentage < 70 )) && (( battery_percentage > 40 )) ; then
      echo -e "─[${Func_Yellow}${battery_icon}${battery_percentage}%${Func_Color_Off}]"
    elif (( battery_percentage < 40 )) ; then
      echo -e "─[${Func_Red}${battery_icon}${battery_percentage}%${Func_Color_Off}]"
    fi
  elif (( ac_adapter_connected == 0 )) ; then
    battery_icon="⚡"
    echo -e "─[${Func_Green}${battery_icon}${Func_Color_Off}]"
  fi
}

_online_status ()
{
  if [ -f /tmp/bash-config/offline ] ; then
    echo -e "${Func_Red}◉${Func_Color_Off}"
  else
    echo -e "${Func_Green}◉${Func_Color_Off}"
  fi
}

# Sets up the prompt
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] ; then
  ps1_header="\u@\h"
else
  ps1_header="\u"
fi

export PS1="\`if [ \$? = 0 ]; then echo ${PS_Green}●${PS_Color_Off}; else \
echo ${PS_Red}●${PS_Color_Off}; fi\`\
─[${PS_Yellow}${ps1_header}${PS_Color_Off}]─[${PS_Blue}\w${PS_Color_Off}]\
\`if [ \$battery_info = y ] ; then _get_battery_info ; fi\`\
\`if [ \$sudo_info = y ] ; then _sudo_status ; fi\`\
\`_git_branch\`─\`if [ \$online_status = y ] ; then _online_status ; else echo ● ; fi\`\
\n└─● "

export PS2="${PS_Green}>>${PS_Color_Off} "
export PS4="${PS_Purple}++${PS_Color_Off} "
