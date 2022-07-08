# sigstore-local-deployment
This automates, and enhances the manual approach to running local Sigstore outlined in [Sigstore the local way](https://github.com/tstromberg/sigstore-the-local-way).  View the README there is gain a deeper insight to the actions being taken here.

This sigstore-local-deployment provides signing a container using cosign against a local OCI registry and the Rekor transparency log.

See `make help` for details of make targets.


## Installation of requirements

### Linux packages
Currently only RHEL/Fedora is supported.  The following packages are required:

* mariadb-server git go softhsm opensc

To install these run:

`make install-packages`

### Go packages

The following are provided are go packages (see `make help` for target details):

* Simple OCI registry
* cosign
* trillian_log_server
* trillian_log_signer
* createtree
* ko

These can be installed by running:

* `make install-registry`
* `make install-cosign`
* `make install-trillian`
* `make install-ko`

## Starting Cosign and dependancies

The easiest way to create a Cosign environment is by running:

`make quickstart`

Once this has been completed run the following to test the installation:

`make post-deploy-tests`

### Logging

All backgrounds processes (Registry, cosign, Trillian etc) are logged via systemd journal, so use `journalctl` to view these.

