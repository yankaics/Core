Core
======

[![Build Status](https://img.shields.io/travis/colorgy/Core/master.svg?style=flat)](https://travis-ci.org/colorgy/Core)
[![Coverage Status](https://img.shields.io/coveralls/colorgy/Core/master.svg?style=flat)](https://coveralls.io/r/colorgy/Core?branch=master)
[![Code Climate](https://img.shields.io/codeclimate/github/colorgy/Core.svg?style=flat)](https://codeclimate.com/github/colorgy/Core)
[![Dependency Status](https://img.shields.io/gemnasium/colorgy/Core.svg?style=flat)](https://gemnasium.com/colorgy/Core)

The core API server & authentication system.


## Development Setup

Just run:

```bash
$ ./bin/setup
```

You may want to change the app's default environment variables, which lays in `.env`.


## Deploy

This application is designed under The [Twelve-Factor App](http://12factor.net/) pattern, making its deployment and operations on cloud platforms easy.

It's also aimed to be Heroku deployable: [![Deploy](https://neson.github.io/GitHub-Badges/deploy_to_heroku_xs.svg)](https://heroku.com/deploy)


## Management

Visit `http(s)://url_of_your_app/admin` to access the control panel. The default account and password is `admin` / `password`. Please change it immediately after your first login by clicking your administration account name ("admin") located at the top-right corner.

You can also type `bin/console` <kbd>Enter</kbd> in the terminal to enter the rails console.

Feel free to check out the [wiki](https://github.com/colorgy/Core/wiki) for further information.


## Testing

Run the following command to execute all test suites:

```bash
$ bundle exec rake
```

For CI or continuous deployment servers, use the `bin/test` command to automatically retry the entire test suite on failure for up to 3 times.


## Chat

[![Join the chat at https://gitter.im/colorgy/Core](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/colorgy/Core?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


## License

Copyright (c) 2015 MISK. Licensed under [GNU AGPL-3.0](https://www.gnu.org/licenses/agpl-3.0.html) with the following conditions:

This software can only be used to power a service where end users are not (able to be) charged for. An additional license should be made if this condition is not obeyed.


## Contributing

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -m 'add some feature'`).
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request.
