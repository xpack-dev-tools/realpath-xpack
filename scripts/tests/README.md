# Scripts to test the GNU realpath xPack

The binaries can be available from one of the pre-releases:

<https://github.com/xpack-dev-tools/pre-releases/releases>

## Download the repo

The test script is part of the GNU realpath xPack:

```sh
rm -rf ${HOME}/Work/realpath-xpack.git; \
git clone \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/realpath-xpack.git  \
  ${HOME}/Work/realpath-xpack.git
```

## Start a local test

To check if GNU realpath starts on the current platform, run a native test:

```sh
bash ${HOME}/Work/realpath-xpack.git/tests/scripts/native-test.sh
```

The script stores the downloaded archive in a local cache, and
does not download it again if available locally.

To force a new download, remove the local archive:

```sh
rm -rf ~/Work/cache/xpack-realpath-*-*
```
