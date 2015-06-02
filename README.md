# Delete any closed branches

## Instalation
The script depends on jshon for reading the JSON response from JIRA

```bash
npm install jshon -g

chomd +x .deleteClosedBranch.sh
```

## Runing the code
Call deleteClosedBranch.sh passing in your Jira username and password as shown below, you will then be prompted to delete and close branches the code finds.

```bash
deleteClosedBranch.sh -u [username] -p [password]
```
