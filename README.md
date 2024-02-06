# SROC Tactical Charging Module

![Build Status](https://github.com/DEFRA/sroc-tcm-admin/workflows/CI/badge.svg?branch=main)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=DEFRA_sroc-tcm-admin&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=DEFRA_sroc-tcm-admin)
[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=DEFRA_sroc-tcm-admin&metric=sqale_index)](https://sonarcloud.io/dashboard?id=DEFRA_sroc-tcm-admin)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=DEFRA_sroc-tcm-admin&metric=coverage)](https://sonarcloud.io/dashboard?id=DEFRA_sroc-tcm-admin)
[![Known Vulnerabilities](https://snyk.io/test/github/DEFRA/sroc-tcm-admin/badge.svg)](https://snyk.io/test/github/DEFRA/sroc-tcm-admin)
[![Licence](https://img.shields.io/badge/Licence-OGLv3-blue.svg)](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3)

The Strategic Review of Charges (SROC) Tactical Charging Module (TCM) is a web application designed to enable billing adminstrators to apply new categories to permit charges to ensure correct amounts are processed.

This service is used by billing administration staff and internally facing only.

## Prerequisites

Make sure you already have:

- [Ruby 2.7.1](https://www.ruby-lang.org/en/)
- [Bundler](http://bundler.io/)
- [PostgreSQL v12](https://www.postgresql.org/)

## Installation

First clone the repository and then drop into your new local repo

```bash
git clone https://github.com/DEFRA/sroc-tcm-admin.git && cd sroc-tcm-admin
```

Next download and install the dependencies

```bash
bundle install
```

## Running locally

There is a separate project available that will build a fully working TCM environment, including an instance of **PostgreSQL** and [Errbit](https://errbit.com/) (used to capture errors) using [Docker](https://docs.docker.com/get-docker/). We recommend contacting the AWS web-ops team and requesting access to **tcm-dev-environment** on our internal GitLab instance.

Else you can install and run the app directly on the host machine.

## Configuration

Any configuration is expected to be driven by environment variables when the service is run in production as per [12 factor app](https://12factor.net/config).

However when running locally in development mode or in test it makes use of the [Dotenv](https://github.com/bkeepers/dotenv) package. This is a shim that will load values stored in a `.env` file into the environment which the service will then pick up as though they were there all along.

Check out [.env.example](/.env.example) for details of the required things you'll need in your `.env` file.

Refer to the [config files](config) for details of all the configuration used.

## Databases

> If you are running the **tcm-dev-environment**, you have nothing to do! All databases are already created and the appropriate ports opened for access from the host to the containers.

If you intend to run it standalone, you'll need to have [PostgreSQL](https://www.postgresql.org/) installed. Then call the following to create the databases for the develop and test environments and seed the DB.

```bash
bundle exec rake db:reset
bundle exec rake db:seed
```

## Running the app

> If you are running the **tcm-dev-environment**, you have nothing to do! The environment comes with VSCode custom tasks available from the [command palette](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette).

Simply start the app using `bundle exec rails s`. If you are in an environment with other Rails apps running you might find the default port of 3000 is in use and so get an error.

If that's the case use `bundle exec rails s -p 8000` swapping `8000` for whatever port you want to use.

## Testing the app

The project originally used [minitest](https://github.com/seattlerb/minitest) for unit testing. Any new tests should be written with [RSpec](https://rspec.info/) as it is the Defra standard for Ruby and Rails based projects. The existing minitests are slowly being reviewed and migrated to RSpec.

```bash
bundle exec rails test
bundle exec rspec
```

Line coverage is combined from the output from both suites.

We also use [rubocop](https://github.com/rubocop/rubocop) to lint the code.

```bash
bundle exec rubocop
```

### Test support endpoints

The app includes endpoints that support our [acceptance tests](https://github.com/DEFRA/sroc-acceptance-tests). They are split between those that are only enabled in our non-production environments and those that can be accessed but you must be an admin. All respond in JSON format.

#### Non-production only

Either because they are destructive or sensitive these endpoints are only available in non-production environments.

> We are referring to when running it locally or in our development, test or pre-production environments. This is different to the Rails environment specified by `RAILS_ENV`.

- `/clean` Will reset most tables in the database. This means, for example, removing all transaction data and resetting the sequence counters. Seeded data, for example, regimes, permit categories and users are retained. We use it to automate resetting the DB for running some of our acceptance tests
- `/last-email` Will return the details and content of the last email sent from the app. We use it to allow us to automate checking the content of emails sent from the system and completing journeys that require following a link provided in an email

#### Admin only

Though built to support testing these endpoints are available in production but only by those with the `admin`. There may be times it would be helpful to perform these tasks outside of a test setting.

- `/jobs/import` trigger the transaction file import process
- `/jobs/export` trigger the transaction file export process

## GOV.UK Notify

The TCM uses [Notify](https://www.notifications.service.gov.uk/using-notify/get-started) to send email. It does this using Notify's [web API](https://docs.notifications.service.gov.uk/ruby.html). The key difference is that the templates for all emails are stored in Notify. Any mailer views found in the TCM code are there purely as reference to what the Notify templates contain and to allow us to replicate the email body.

## Contributing to this project

If you have an idea you'd like to contribute please log an issue.

All contributions should be submitted via a pull request.

## License

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

<http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3>

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government license v3

### About the license

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable information providers in the public sector to license the use and re-use of their information under a common open licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
