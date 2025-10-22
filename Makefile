# Minimal makefile for Sphinx documentation.
# This is not used by ReadtheDocs.

VENV = .venv
VENV_READY = $(VENV)/.venv_ready
VENV_BIN = $(VENV)/bin

# Try to use python3 else python
SYSTEM_PYTHON = $(shell which python3 2>/dev/null)
ifeq ($(strip $(SYSTEM_PYTHON)),)
	SYSTEM_PYTHON = $(shell which python 2>/dev/null)
endif


# You can set these variables from the command line.
SPHINXOPTS  =
SPHINXBUILD = sphinx-build
SPHINXPROJ  = UnboundUserManual
SOURCEDIR   = source
BUILDDIR    = build


# Put it first so that "make" without argument is like "make help".
.PHONY: help
help: $(VENV_READY)
	. $(VENV_BIN)/activate && $(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

# Local virtual environment for easier local build
$(VENV_READY): $(VENV)
	. $(VENV_BIN)/activate && pip install -U pip pip-tools
	. $(VENV_BIN)/activate && pip install -Ur requirements.txt
	touch $(VENV_READY)

$(VENV):
	$(SYSTEM_PYTHON) -m venv $(VENV)

.PHONY: venv_update
venv_update: $(VENV_READY)
	. $(VENV_BIN)/activate && pip install -U pip pip-tools
	. $(VENV_BIN)/activate && pip install -Ur requirements.txt

.PHONY: venv_clean
venv_clean:
	rm -rf $(VENV)

# For the man mode do not replace Unbound configure variables with their
# default values.
.PHONY: man Makefile
man: Makefile $(VENV_READY)
	@test -d $(unbound_dir) -a -d $(unbound_dir)/doc || (echo "unbound_dir is probably not set! Did you use 'make man unbound_dir=/path/to/unbound/repo' ?" && false)
	@bash scripts/prepare_manpages.sh $(unbound_dir) && echo "Getting rst man pages from $(unbound_dir) ..."
	. $(VENV_BIN)/activate && UNBOUND_NO_VERSION_FROM_REPO= $(SPHINXBUILD) -M man "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O) -D today="@date@"
	@bash scripts/copy_built_manpages.sh $(unbound_dir) && echo "Copied templated manpages back to $(unbound_dir)/doc"

# The 'localhtml' target is the same as the 'html' target (caught below and
# passed to Sphinx) but allows for using a local unbound repo to get the man
# pages from.
# Mostly used for development/debugging of new Sphinx/RST features.
.PHONY: localhtml Makefile
localhtml: Makefile $(VENV_READY)
	@test -d $(unbound_dir) -a -d $(unbound_dir)/doc || (echo "unbound_dir is probably not set! Did you use 'make localhtml unbound_dir=/path/to/unbound/repo' ?" && false)
	@bash scripts/prepare_manpages_with_defaults.sh $(unbound_dir) && echo "Getting rst man pages from $(unbound_dir) and filling in defaults ..."
	. $(VENV_BIN)/activate &&                                $(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
# For the rest of the modes replace Unbound configure variables with their
# default values.
%: Makefile $(VENV_READY)
	@bash scripts/prepare_manpages_with_defaults.sh && echo "Getting rst man pages from git submodule and filling in defaults ..."
	. $(VENV_BIN)/activate &&                                $(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
