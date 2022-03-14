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
- [PostgreSQL v12](https://www.postgresql.org/)

## Installation

First clone the repository and then drop into your new local repo

```bash
git clone https://github.com/DEFRA/sroc-tcm-admin.git && cd sroc-tcm-admin
```

Our preference is to run the database and API within Docker, so [install Docker](https://docs.docker.com/get-docker/) if you don't already have it.

## Configuration

Any configuration is expected to be driven by environment variables when the service is run in production as per [12 factor app](https://12factor.net/config).

However when running locally in development mode or in test it makes use of the [Dotenv](https://github.com/bkeepers/dotenv) package. This is a shim that will load values stored in a `.env` file into the environment which the service will then pick up as though they were there all along.

Check out [.env.example](/.env.example) for details of the required things you'll need in your `.env` file.

Refer to the [config files](config) for details of all the configuration used.

## Docker

As [Docker](https://www.docker.com/) is our chosen solution for deploying and managing the app in production we also use it for local development. The following will get an environment up and running quickly ready for development. It assumes 2 things

- you have Docker installed
- you are using [VSCode](https://code.visualstudio.com/) for development

### Initial build

Open the project in VSCode and then use the [Command palette](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette) to access the tasks we have provided in [tasks.json](.vscode/tasks.json)

With the palette open search for **Run test task** and once highlighted select it. From the list that's presented select **⬆️ UP (TCM)**

You should see a new terminal open up and [Docker Compose](https://docs.docker.com/compose/) begin to start building the images. Once that is done it will switch to running the API in docker.

### Prep the databases

The main database is automatically created but the 'test' database is not. Plus both need the [DB migrations](/db/migrate) to be run against them, and the main database needs to be [seeded](/db/seeds).

The good news is all this is automated. Again, using the command palette and the **Run test task** option find and select **🗄️ DB (TCM)**. It will setup both databases and leave the API ready for use.

> You can also use this same command to reset the databases at anytime

### Non-vscode users

If you are not a VSCode user it does not mean you cannot use Docker. Refer to [tasks.json](.vscode/tasks.json) for the commands being run and implement them in your preferred tool.

## Testing the app

The project originally used [minitest](https://github.com/seattlerb/minitest) for unit testing. Any new tests should be written with [RSpec](https://rspec.info/) as it is the Defra standard for Ruby and Rails based projects. The existing minitests are slowly being reviewed and migrated to RSpec.

To run both suites together use the command palette and the **Run test task** option to find and select

- **✅ TEST (TCM)**

To run just the minitest suite find and select

- **✅ MINITEST (TCM)**

To run just the RSpec suite find and select

- **✅ RSPEC (TCM)**

We also use [rubocop](https://github.com/rubocop/rubocop) to lint the code. To run it find and select

- **🔎 LINT (TCM)**

### Test support endpoints

The app includes endpoints that support our [acceptance tests](https://github.com/DEFRA/sroc-acceptance-tests). They are split between those that are only enabled in our non-production environments and those that can be accessed but you must be an admin. All respond in JSON format.

#### Non-production only

Either because they are distructive or sensitive these endpoints are only available in non-production environments.

> We are referring to when running it locally or in our development, test or pre-production environments. This is different to the Rails environment specified by `RAILS_ENV`.

- `/clean` Will reset most tables in the database. This means, for example, removing all transaction data and resetting the sequence counters. Seeded data, for example, regimes, permit categories and users are retained. We use it to automate resetting the DB for running some of our acceptance tests
- `/last-email` Will return the details and content of the last email sent from the app. We use it to allow us to automate checking the content of emails sent from the system and completing journeys that require following a link provided in an email

#### Admin only

Though built to support testing these endpoints are available in production but only by those with the `admin`. There may be times it would be helpful to peform these tasks outside of a test setting.

- `/jobs/import` trigger the transaction file import process
- `/jobs/export` trigger the transaction file export process

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
