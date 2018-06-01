# Hashi-pkg

Downloads a hashicorp tool and creates packages for installation via yum or apt

**Please note**: This tool is _not_ created, supported and/or endorsed by Hashicorp. Use at your own risk etc


### Why

Hashicorp distribute their tools in .zip files. This is a no nonsense way to get the software out in to the world quickly.

However this can be an faf when updates are realeased and existing systems need
to be updated.

Plugging the tools in to a users package manager can help keep things up to date and ensure an consistent installation environment.



## How

For ease all operations are triggered via a `Makefile`

To avoid adding extra junk to your system this makes use of a docker container with packaging tools installed in to it.

To build the image run the following on your system:

```shell
make build
```

To get the latest terraform and turn it in to a package run the following:

```shell
make go
```

To get an older version of terraform specify the version, like so:

```shell
make VERSION="0.7.4" go
```

To specify an alternate tool specify the tool name, like so:

```shell
make TOOL="packer" go
```

The `TOOL` and `VERSION` can be specified together to get specific versions of tools.
If these variables are not specified it will default to getting and packaging the latest version of terraform.



## Todo

There are some things to be aware of:

* The tool does not currently verify the crypographic signatues provided by hahicorp
* Due to the format of the changelog being different to what the rpm builder tool expects so is not included in the package build.
* The Docker image includes some tools that are not used right now leading to a larger image ( vim, repo building tools etc )

