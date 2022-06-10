Unbound for Python
==================

Pyunbound
---------

Unbound supports bindings for Python which we call 'pyunbound'. This
functionality can be enabled in the :command:`configure` step of the
installation using the following option:

.. code-block:: bash

    ./configure --with-pyunbound

Documentation for pyunbound will then also be included when building Unbound's
documentation with:

.. code-block:: bash

    make doc

This command will generate the relevant pyunbound documentation in
``doc/html/pyunbound``, which can be browsed in a web browser by opening the
``index.html`` file in that directory.

The pyunbound documentation can also be solely generated without the need to
configure/compile Unbound by invoking :command:`sphinx-build` directly with:

.. code-block:: bash

    sphinx-build -b html libunbound/python/doc doc/html/pyunbound/

Pythonmod
---------

Unbound contains a module that executes python code called 'pythonmod'. The
supplied Python code has to follow module operation semantics. This module is
enabled in the :command:`configure` step of the installation using the
following option:

.. code-block:: bash

    ./configure --with-pythonmodule

Documentation for pythonmod will then also be included when building Unbound's
documentation with:

.. code-block:: bash

    make doc

This command will generate the relevant pythonmod documentation in
``doc/html/pythonmod``, which can be browsed in a web browser by opening the
``index.html`` file in that directory.

The pythonmod documentation can also be solely generated without the need to
configure/compile Unbound by invoking :command:`sphinx-build` directly with:

.. code-block:: bash

    sphinx-build -b html pythonmod/doc/ doc/html/pythonmod/
