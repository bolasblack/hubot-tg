# Hubot tg

Connect telegram via [tg](https://github.com/vysheng/tg)

## Installation

```bash
npm install bolasblack/hubot-tg --save
cd ./node_modules/hubot-tg/telegram-cli-wrapper/tg
bin/telegram-cli -k server.pub
# Login by follow the guide of tg
```

Install `telegram-cli-wrapper` follow the [document](https://github.com/bolasblack/telegram-cli-wrapper#installation)

## Configuration

```bash
export TELEGRAM_PHONE_NUMBER=...
```

## Limitation

* Only support text message now
* Only support `send` and `reply` now
