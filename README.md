# hledger docker image

## Features

* non-root user and group `hledger` to mitigate security risks
* multi-platform image supports ARM64 devices as well (e.g. Raspberry PI)

**For custom images using Dockerfile**

* specify UID / GID for `hledger:hledger`
* specify hledger-* binaries to be installed
* specify base images

## Usage

**Web server**

```yaml
services:
  hledger-web:
    image: bharathcs2401/hledger:1.34
    volumes:
      - /path/to/hledger-data:/data
    ports:
      - 5000
    command: hledger-web --serve --host=0.0.0.0 port=5000 --file='/data/main.ledger'
```

**Long running container**

Most docker containers have just one process and aren't meant to live longer. However, if you wish
to, you may force it to stay alive and accessible via
`docker exec -it CONTAINER_NAME_OR_ID COMMAND ...ARGS`.

* you want to be able to start and stop the hledger-web instance separately from the container's lifetime
* providing hledger shell access via REST, but you do not want to give access to your machine to be
  extra safety
* if you do not want to install hledger on your machine for some other reason

```
services:
  hledger:
    image: bharathcs2401/hledger:1.34
    volumes:
      - /path/to/hledger-data:/data
    ports:
      - 5000
    command: tail -f /dev/null
```

## User management

For improved security, the container drops from `root` user (default on docker containers) to a
non-root `hledger` user with group `hledger`. Default IDs used are `UID=3913, GID=3913`. When the
container starts, it recursively takes ownership of and fixes permissions of `/data` to
`u=rwX,g=rwX,o=`. You may use volume to map your hledger files to `/data` in the container

As docker relies on the host kernel's user management, you will find that mapped files are only
accessible to a user with ID 3913 or a user belonging to a group with ID 3913. To regain access, do
ONE of the following:

* Create a hledger group with id `3913`, and add your user to it
* Set up a hledger user and hledger group in the host with `UID=3913, GID=3913`, and switch to it
  before accessing the shared
* build your own image using the dockerfile and with custom UID and GID such that fixing the
  permissions still gives you access

## Dockerfile arguments

If you would like to customise your build, use
[build arguments](https://docs.docker.com/build/guide/build-args/) with [Dockerfile](./Dockerfile)
provided, through a `docker-compose.yml` that specifies build or through `docker build ...`.

| build arg | description | default |
| :--- | :--- | :--- |
| HLEDGER_UID | `hledger` user in container that owns and modifies `/data` | 3913 |
| HLEDGER_GID | Primary group of `hledger` user in container | 3913 |
| HLEDGER_PACKAGES | Packages to install in the container | 'hledger-1.34,hledger-web-1.34,hledger-ui-1.34,hledger-interest-1.6.6' |
| HASKELL_RESOLVER | Used in installing haskell packages [more info](https://docs.haskellstack.org/en/stable/stack_yaml_vs_cabal_package_file/#snapshots-and-resolvers) | nightly |
| HASKELL_IMG | Base image for installing haskell packages | haskell:slim-buster |
