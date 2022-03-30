# morobi
Multi-purpose and modular bot with a primitive multilingual engine being tailor-made for my personal Discord server.

Recommended start command:
```
bundle exec ruby -w morobi.rb
```

discord.rb needs libsodium for voice chat interaction. If you have sodium installed, you can tell Morobi to use it by providing a folder (with the `-I` flag) where sodium's binaries are stored. Example: `-I ./libs`.