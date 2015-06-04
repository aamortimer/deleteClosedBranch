#!/bin/bash

if (($# == 0)); then
    echo ""
    echo "Available flags:"
    echo "-u jira user"
    echo "-p jira password"
    echo ""
    exit 1
fi

while getopts ":u:p:" opt; do
    case $opt in
        u)
            # Jira Username
            USERNAME=$OPTARG ;;
        p)
            # Jira Password
            PASSWORD=$OPTARG ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done


## need to removed folder from branch
for BRANCH in $(git branch | grep -v "\*" | xargs -n 1); do
    JIRA_BRANCH=$(sed "s/.*\///g" <<< $BRANCH)

    TICKET=$(curl -s -u $USERNAME:$PASSWORD -H "Content-Type: application/json" https://tuispecialist.atlassian.net/rest/api/2/issue/$JIRA_BRANCH)
 
    ERROR_MESSAGE=$(jshon -Q -e errorMessages -u  <<< $TICKET)
    
    if [ "$ERROR_MESSAGE" != 'Issue Does Not Exist' ]; then
        TICKET_STATUS=$(jshon -Q -e fields -e status -e name -u <<< $TICKET)
        TICKET_SUMMARY=$(jshon -Q -e fields -e summary -u <<< $TICKET)

        if [ "$TICKET_STATUS" == 'Closed' ] ; then
            printf "$BRANCH $TICKET_SUMMARY \e[00;32m[CLOSED]\e[00m\n"

            read -p $'\e[31mDelete branch?\e[0m: (y/n)' CONT
            if [ "$CONT" == "y" ]; then
             # git branch -rd "origin/$GIT_BRANCH"
             # git fetch -p
              echo "DELETED Branch $BRANCH\n";
            fi
        fi

    fi
done
