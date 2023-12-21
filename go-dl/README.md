# go-dl

A simple Bash script to download and install the latest version of
Golang from their official website.

Mostly intended for use in environments
where the official repositories have older versions (stable release distros)
and you'd like to use or tinker with the latest features, or you simply need a
newer version for whatever reason and don't feel like messing around with VMs or
containers.

## Usage

The only requirement is the `bash` shell and superuser permisions as they are
needed according to Go's official [install instructions](https://go.dev/doc/install).

By default, the script will look for, download and install the latest Go version
available in their [downloads webpage](https://go.dev/dl/), but you can also
explicitly pass the "`latest`" string as an argument, which will have the exact
same result (see [TODO](#todo)).

You can either clone the repo and run the script locally, or paste the following
code in your terminal of choice:

```bash
curl -Ssf "https://raw.githubusercontent.com/saeram00/scripts/main/go-dl/src/go-dl.sh" | bash
```

## TODO

* As of now, the script only checks for the [latest](https://go.dev/dl/) version
and installs it on your system using Go's website official
[install instructions](https://go.dev/doc/install).  
In the future I would like to add a version selection function, to download
and install the specified version of go from their official website.

* I may work on a POSIX `sh` compatible version sometime in the future for
environments where Bash is not installed for whatever reason. However, keep in
mind that is not a priority at the moment.
