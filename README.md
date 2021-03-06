# Igor <img src="http://i.imgur.com/GDEhZbY.png" width="100"/>

[![Build Status](https://travis-ci.org/dimagi/igor.svg?branch=master)](https://travis-ci.org/dimagi/igor)

Igor is a chat bot built on the [Hubot][hubot] framework. It was
initially generated by [generator-hubot][generator-hubot].


[hubot]: http://hubot.github.com
[generator-hubot]: https://github.com/github/generator-hubot

### Requirements

In order to run igor you will need:

- nodejs
- elasticsearch >2.0 (Only necessary if you're using the search capabilities)
- redis (for the brain)

### Running Igor Locally

You can test your hubot by running the following, however some plugins will not
behave as expected unless the configuration they rely
upon have been set. You can find an example config file in the `config` directory.

You can start Igor locally by running:

    % bin/hubot

You'll see some start up output and a prompt:

    [Sat Feb 28 2015 12:38:27 GMT+0000 (GMT)] INFO Using default redis on localhost:6379
    Igor>

Then you can interact with Igor by typing `igor help`.

    igor> igor help
    igor animate me <query> - The same thing as `image me`, except adds [snip]
    igor help - Displays all of the help commands that igor knows about.
    ...

To connect to the slack client you'll need to specify the Slack token which can be found [here](https://dimagi.slack.com/services/B0CDDUNAH). Now to run hubot locally you can run:

    % HUBOT_SLACK_TOKEN=<token> NODE_ENV=local ./bin/hubot --adapter slack

### Running Tests

```
npm test
```

### Deploying

You can deploy Mia by running `fab deploy`. You'll have to install the requirements first by running:

```
pip install -r requirements.txt
```

### Scripting

An example script is included at `scripts/example.coffee`, so check it out to
get started, along with the [Scripting Guide](scripting-docs).

For many common tasks, there's a good chance someone has already one to do just
the thing.

[scripting-docs]: https://github.com/github/hubot/blob/master/docs/scripting.md

### external-scripts

There will inevitably be functionality that everyone will want. Instead of
writing it yourself, you can use existing plugins.

Hubot is able to load plugins from third-party `npm` packages. This is the
recommended way to add functionality to your hubot. You can get a list of
available hubot plugins on [npmjs.com](npmjs) or by using `npm search`:

    % npm search hubot-scripts panda
    NAME             DESCRIPTION                        AUTHOR DATE       VERSION KEYWORDS
    hubot-pandapanda a hubot script for panda responses =missu 2014-11-30 0.9.2   hubot hubot-scripts panda
    ...


To use a package, check the package's documentation, but in general it is:

1. Use `npm install --save` to add the package to `package.json` and install it
2. Add the package name to `external-scripts.json` as a double quoted string

You can review `external-scripts.json` to see what is included by default.

##### Advanced Usage

It is also possible to define `external-scripts.json` as an object to
explicitly specify which scripts from a package should be included. The example
below, for example, will only activate two of the six available scripts inside
the `hubot-fun` plugin, but all four of those in `hubot-auto-deploy`.

```json
{
  "hubot-fun": [
    "crazy",
    "thanks"
  ],
  "hubot-auto-deploy": "*"
}
```

**Be aware that not all plugins support this usage and will typically fallback
to including all scripts.**

[npmjs]: https://www.npmjs.com
