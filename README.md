# Delete any closed branches

## Instalation
```bash
npm install git-old-jira-branches -g
```

## Setup
You have two methods for setting up the code the preferred way is to save your username, password and [host](#host) to [git config](#git-config-setup), the alternative approach is to pass the [arguments](#cli-arguments) into ```git-old-jira-branches```.

### Host
The Jira host should be just the base url i.e. **jira.atlassian.com** the rest of the URL is added via the code.

### Git config setup
```bash
git config jira.username [username]
git config jira.password [passwrd]
git config jira.host [host]
```

### CLI Arguments
```bash
git-old-jira-branches -u [username] -p [password] -h [jira host url]
```
