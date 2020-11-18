# macos-self-sign-app
A script for signing an App so that it will open without needing to ask permission from big brother Apple.

I wrote this script based on [this thread](https://apple.stackexchange.com/questions/64408/can-you-disable-a-code-signature-check)
<br>
And it was created to solve [this problem](https://www.reddit.com/r/hackintosh/comments/ju5cik/every_appstore_app_crashes_instantly/).
<br>
I tested it on Pages, iMovie, and GarageBand.

<br>

The script can either ***tell*** you what commands to run, or ***run*** the commands itself (but it will need your password to run them).
**Pasting random commands from the internet into your terminal is generally a really really bad idea**. You should probably read the code, its only 100 lines in [main.rb](https://raw.githubusercontent.com/jeff-hykin/macos-self-sign-app/main/main.rb) and it reads a lot like English. But if you're feelin lucky, I guess you can just run the command below.

Open the Terminal App, paste this (then press enter). The script itself will lead you through the rest of the process.
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/jeff-hykin/macos-self-sign-app/main/main.rb)"
```