#!/bin/bash

# libary
JSHON="/usr/local/lib/node_modules/git-old-jira-branches/node_modules/jshon/jshon"

# # settings
USERNAME="$(git config jira.username)"
PASSWORD="$(git config jira.password)"
HOST="$(git config jira.host)"

# # type
BOLD="\e[01m"

# # colours
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[00m"


while getopts ":u:p:a:" opt; do
    case $opt in
        u)
            # Jira Username
            USERNAME=$OPTARG ;;
        p)
            # Jira Password
            PASSWORD=$OPTARG ;;
        h)
            # Jira API
            HOST=$OPTARG ;;
    esac
done

if [ -z $USERNAME ] || [ -z $PASSWORD ] || [ -z $HOST ]; then
    printf "\n${RED}You must supply a 'Username', 'Password' AND 'HOST'.\n"
    printf "You can supply these by setting 'git congig' settings or pass them in as command line arguments.${RESET}\n\n"
    printf "To setup git config settings run the following commands.\n\n"
    printf "${GREEN}\tgit config jira.username [username] #your jira username\n"
    printf "\tgit config jira.password [password] #your jira password\n"
    printf "\tgit config jira.host [host] #this should be the jira url i.e jira.atlassian.net\n\n"
    printf "${RESET}Or you can pass these options in as arguments with the following\n"
    printf "${GREEN}\tgit-old-jira-branches -u [username] -p [password] -h [host]\n${RESET}\n"

    exit 1;
fi

printf "${BLUE}###########################################################################################${RESET}"
printf "\n\t${BOLD}Running checks on git branches, please be patient this could take some time.${RESET}\n"
printf "${BLUE}###########################################################################################${RESET}\n\n"

## need to removed folder from branch
for BRANCH in $(git branch -a --merged master| grep -v "\*" | xargs -n 1); do
    JIRA_BRANCH=$(sed "s/.*\///g" <<< $BRANCH)

    TICKET=$(curl -s -u $USERNAME:$PASSWORD -H "Content-Type: application/json" https://$HOST/rest/api/2/issue/$JIRA_BRANCH)
    ERROR_MESSAGE=""

    if [ "$($JSHON -e errorMessages -t 2> /dev/null <<< $TICKET)" == "array" ]; then
        ERROR_MESSAGE=$($JSHON -Q -e errorMessages -e 0 -u  <<< $TICKET)
    fi

    if [ "$ERROR_MESSAGE" != 'Issue Does Not Exist' ]; then
        TICKET_STATUS=$($JSHON -Q -e fields -e status -e name -u <<< $TICKET)
        TICKET_SUMMARY=$($JSHON -Q -e fields -e summary -u <<< $TICKET)

        printf "Found ticket ${BOLD}$JIRA_BRANCH${RESET} with the following status ${BOLD}[$TICKET_STATUS]${RESET}\n"

        if [ "$TICKET_STATUS" == 'Closed' ] || [ "$TICKET_STATUS" == "In Live Environment" ] ; then
            printf "\n\n${BLUE}${BOLD}Do you want to delete${RESET}:"
            printf "\n${BOLD}$BRANCH $TICKET_SUMMARY [$TICKET_STATUS]${RESET}\n"

            echo "The following commands will be run, please make sure you confirm you really want to delete these."
            printf "\n${RED}git branch -D '$BRANCH'${RESET}";
            printf "\n${RED}git push origin :$BRANCH${RESET}";
            read -p $'\n${RED}Delete branch?${RESET}: (y/n) ' CONT

            if [ "$CONT" == "y" ]; then
              git branch -D $BRANCH > /dev/null 2>&1
              git push origin :BRANCH > /dev/null 2>&1
              printf "${GREEN}DELETED Branch \e[01m$BRANCH${RESET}\n\n";
            fi
        fi
    fi
done

printf "\e[01mFinished.\e[00m\n"
