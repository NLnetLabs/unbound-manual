# unbound-manual
The Official Unbound User Manual, published at [unbound.docs.nlnetlabs.nl](https://unbound.docs.nlnetlabs.nl/).


## Style Guide

This manual uses British English. Since there is quite a bit of leeway in
English style, we use the [European Commission’s English Style Guide] as
guidance.

[European Commission’s English Style Guide]: https://ec.europa.eu/info/sites/info/files/styleguide_english_dgt_en.pdf


## Overview

The documentation here relies on [Sphinx](https://www.sphinx-doc.org) which is
a documentation generator written in Python.

There is a pinned Unbound git submodule that should track the latest Unbound
version; **online** manpage generation on ReadtheDocs relies on that.

The included Makefile (which is not used by ReadtheDocs) takes care of
installing a local Python virtual environment for Sphinx that helps with
buidling locally.

Local builds are only useful when manpages need to be generated for the master
version of Unbound.
That is an when an \*.rst manpage was edited in the Unbound repository and then
Sphinx from this repository can generate the troff template manpage for the
Unbound repository.


## Generating manpages for the Unbound master branch

```
make man unbound_dir=</path/to/local/unbound/repo>
```
This will copy the .rst manpages from the provided Unbound repository,
invoke Sphinx to build the manpages and copy the templates (*.in) back to
the same Unbound repository.


## Releasing new versions

When a new Unbound version is released, update the Unbound submodule to point
to the appropriate release tag/branch.

[!TIP]
Before building on ReadtheDocs, the script in
`scripts/prepare_manpages_with_defaults.sh` is invoked (see .readthedocs.yaml)
to fill in the manpages with default values for the online documentation.
