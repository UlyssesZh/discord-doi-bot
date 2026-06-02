# discord-doi-bot

A Discord bot that fetches metadata from a DOI and posts it in a channel.
Powered by [Serrano](https://github.com/sckott/serrano).

Needs message content intent.

## Usage

A message that contains a DOI in one of the following forms can trigger the bot:

```plain
doi:10.3102/00028312014004367
http://doi.org/10.3102/00028312014004367
https://doi.org/10.3102/00028312014004367
```

## Deploy

Use the following Docker compose file:

```yaml
services:
  app:
    container_name: discord-doi-bot
    image: ulysseszhan/discord-doi-bot
    environment:
      DISCORD_DOI_BOT_TOKEN: y0ur.T0ken
    restart: unless-stopped
```

You can optionally set `DISCORD_DOI_BOT_CROSSREF_BASE_URL`
and `DISCORD_DOI_BOT_CROSSREF_MAILTO` in the environment.
See [doc](https://github.com/sckott/serrano#setup) of Serrano for details.

## License

MIT.
