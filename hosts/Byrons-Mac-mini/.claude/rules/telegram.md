# Telegram notifications

A Telegram bot is available for contacting the user. Use it to send notifications - for example when a long task finishes, when input is needed, or when something requires attention.

- **Token**: stored in Doppler as `TELEGRAM_BOT_TOKEN` in the `global` project, `home` config. Never hardcode it. Fetch on demand:
  ```sh
  doppler run --project global --config home -- <command using $TELEGRAM_BOT_TOKEN>
  ```
- **Chat ID**: `8851680837` (Byron). This is the destination for all messages.
- **Purpose**: this channel reaches the user directly. Use it for notifications, not for chatty or routine output.
- **Sending a message**:
  ```sh
  doppler run --project global --config home -- bash -c \
    'curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
      -d chat_id=8851680837 --data-urlencode text="your message here"'
  ```
