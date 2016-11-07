#!/bin/bash

USERNAME="$(git config jira.username)"
PASSWORD="$(git config jira.password)"
API="$(git config jira.api)"

while getopts ":u:p:a:" opt; do
    case $opt in
        u)
            # Jira Username
            USERNAME=$OPTARG ;;
        p)
            # Jira Password
            PASSWORD=$OPTARG ;;
        a)
            # Jira API
            API=$OPTARG ;;
    esac
done

if [ -z $USERNAME ] || [ -z $PASSWORD ] || [ -z $API ]; then
    printf "\n\e[31mYou must supply a 'Username', 'Password' AND 'API'.\n"
    printf "You can supply these by setting 'git congig' settings or pass them in as command line arguments.\e[00m\n\n"
    printf "To setup git config settings run the following commands.\n\n"
    printf "\e[32m\tgit config jira.username [username]\n"
    printf "\tgit config jira.password [password]\n"
    printf "\tgit config jira.api [api]\n\n"
    printf "\e[00mOr you can pass these options in as arguments with the following\n"
    printf "\e[32m\tgit-old-jira-branches -u [username] -p [password] -a [api]\n\e[00m\n"

    exit 1;
fi


printf "\e[34m###########################################################################################\e[00m"
printf "\n\t\e[01mRunning checks on git branches, please be patient this could take some time.\e[00m\n"
printf "\e[34m###########################################################################################\e[00m\n\n"

## need to removed folder from branch
for BRANCH in $(git branch -a | grep -v "\*" | xargs -n 1); do
    JIRA_BRANCH=$(sed "s/.*\///g" <<< $BRANCH)

    TICKET=$(curl -s -u $USERNAME:$PASSWORD -H "Content-Type: application/json" https://$API/rest/api/2/issue/$JIRA_BRANCH)

    ERROR_MESSAGE=$(jshon -Q -e errorMessages -e 0 -u  <<< $TICKET)

    if [ "$ERROR_MESSAGE" != 'Issue Does Not Exist' ]; then
        TICKET_STATUS=$(jshon -Q -e fields -e status -e name -u <<< $TICKET)
        TICKET_SUMMARY=$(jshon -Q -e fields -e summary -u <<< $TICKET)

        printf "Found ticket \e[01m$JIRA_BRANCH\e[00m with the following status \e[00;36m[$TICKET_STATUS]\e[00m\n"

        if [ "$TICKET_STATUS" == 'Closed' ] || [ "$TICKET_STATUS" == "In Live Environment" ] ; then
            printf "\n\n\e[34m\e[01mDo you want to delete\e[0m:"
            printf "\n\e[01m$BRANCH $TICKET_SUMMARY \e[00;36m[$TICKET_STATUS]\e[00m\n"

            echo "The following commands will be run, please make sure you confirm you really want to delete these."
            printf "\n\e[00;31mgit branch -D '$BRANCH'\e[00m";
            printf "\n\e[00;31mgit push origin :$BRANCH\e[00m";
            read -p $'\n\e[34mDelete branch?\e[0m: (y/n) ' CONT

            if [ "$CONT" == "y" ]; then
              git branch -D $BRANCH > /dev/null 2>&1
              git push origin :BRANCH > /dev/null 2>&1
              printf "\e[32mDELETED Branch \e[01m$BRANCH\e[00m\n\n";
            fi
        fi

    fi
done

printf "\e[01mFinished.\e[00m\n"
