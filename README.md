# rack-webrick-frozen-str-issue

`Webrick` `1.8.0` is incompatible with `rack` `2.2.6.2`, because it introduced "frozen" strings.
Version `1.7.0` still works.

You can run an example with:
```sh
bundle exec ruby ./lib/rack-webrick-frozen-str-issue.rb
```

Example error logs can be found [here](./example/error.log).
