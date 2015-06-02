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
            # Jira and SVN Username
            USERNAME=$OPTARG ;;
        p)
            # Jira and SVN Password
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

for BRANCH in $(git branch | xargs -n1 basename); do
    TICKET=$(curl -s -u $USERNAME:$PASSWORD -H "Content-Type: application/json"  https://tuispecialist.atlassian.net/rest/api/2/issue/$BRANCH) 
    ERROR_MESSAGE=$(jshon -Q -e errorMessages -u  <<< $TICKET)

    if [ "$ERROR_MESSAGE" != 'Issue Does Not Exist' ]; then
        TICKET_STATUS=$(jshon -Q -e fields -e status -e name -u <<< $TICKET)
        TICKET_SUMMARY=$(jshon -Q -e fields -e summary -u <<< $TICKET)

        if [ "$TICKET_STATUS" == 'Closed' ] ; then
            printf "$BRANCH $TICKET_SUMMARY \e[00;32m[CLOSED]\e[00m\n"

            read -p $'\e[31mDelete branch?\e[0m: (y/n)' CONT
            if [ "$CONT" == "y" ]; then
              git branch -rd "$BRANCH"
              echo "DELETED Branch $BRANCH\n";
            fi
        fi
    fi
done
