update-icon
===========

## How to deploy
### Easiest way
coming soon...

### Easy way
`heroku-toolbelt` required.

```
$ heroku apps:create APP_NAME
$ heroku config:set CONSUMER_KEY...
$ git push heroku master
```

## Config Vars

```
CONSUMER_KEY=""
CONSUMER_SECRET=""
ACCESS_TOKEN=""
ACCESS_TOKEN_SECRET=""

SCREEN_NAME=""
BANNED_USERS=""

# Optional - use for user authentication

LOGIN_CONSUMER_KEY=""
LOGIN_CONSUMER_SECRET=""
```

- `SCREEN_NAME` is the account's you want to change the icon.
- You can set `BANNED_USERS`(comma separated values).
- `LOGIN_CONSUMER_KEY` and `LOGIN_CONSUMER_SECRET` is optional vars.
