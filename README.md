Planit
======

GETTING STARTED FROM GITHUB

You'll need a `config/application.yml` file to store environment variables. At the very least, you'll want:

```yaml
SECRET_KEY_BASE: generate-your-own
DEVISE_SECRET_TOKEN: generate-your-own
ASSET_PATH: localhost:3000
DB_OWNER: your-username
PRODUCTION_APP: planit-app
TIMEOUT_IN_SECONDS: '15'

development:
  RACK_ENV: 'development'
  ASSET_PATH: 'http://localhost:3000'

production:
  ASSET_PATH: https://d3er4pdqnow1z.cloudfront.net
  TIMEOUT_IN_SECONDS: '15'
```

We're using [Rails Assets](https://rails-assets.org/) for most of our included JS, so you shouldn't need to Bower/Node install anything. Just bundle and go. 

**However**, install is likely to be messy. We'd really appreciate it if you take note of what steps you take to install successfully, so we can improve this install readme.