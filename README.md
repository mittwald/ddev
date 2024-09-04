<h1 align="center">mittwald DDEV addon</h1>

<p align="center">
    <a href="#synposis">ℹ️ Synopsis</a> |
    <a href="#installation">⚒️ Installation instructions</a> |
    <a href="#usage">🙆 Usage</a>
</p>

---

## Synopsis

This repository contains a [DDEV addon][addon] for the mittwald hosting platform. It adds the following features to your DDEV project:

- Synchronizing your DDEV configuration with the current state of your mittwald cloud project
- Pulling and pushing your project's code and database contents from and to the mittwald cloud platform.
- Using the [mittwald CLI][cli] in your DDEV web environment

## Installation

This addon has the following requirements:

- DDEV (obviously)
- An API token for the [mittwald mStudio v2 API][api-intro]; you will be prompted for this token during the installation process (if not already configured)
- An existing application on the mittwald cloud; you will need the application id (formatted like `a-XXXXXX`).

You can install this addon by running `ddev get`:

```
$ ddev get mittwald/ddev
```

The installation process will prompt you for a [mittwald API token][api-intro] and your application ID. The former will be added to your global DDEV configuration, the latter to your local project configuration.

## Usage

Installing the mittwald DDEV addon allows you to use the following commands:

- `ddev pull mittwald` will download the filesystem and database contents of the linked application to your local DDEV project.
- `ddev push mittwald` will upload the filesystem and database contents back to the mittwald cloud platform. **CAUTION**: Keep in mind that this is a dangerous operation and not meant to be used as a robust, production-ready deployment solution. Have a look at our [documented deployment guides][deployment] to learn more about production-grade deployments.
- `ddev mw ...` allows you to run the [mittwald CLI][cli] in your web container.

[addon]: https://ddev.readthedocs.io/en/stable/users/extend/additional-services/
[cli]: https://github.com/mittwald/cli
[api-intro]: https://developer.mittwald.de/docs/v2/api/intro/
[deployment]: https://developer.mittwald.de/docs/v2/category/deployment-guides/
