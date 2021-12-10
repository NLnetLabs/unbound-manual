Python Modules
--------------

Pyunbound
*********

Unbound supports bindings for Python which we call 'pyunbound'. We enable this functionility in the :command:`configure` step of the installation using the following command.

.. code:: bash

    ./configure --with-pyunbound

We can then generate the documentation for this using:

.. code:: bash

    make doc

This command will genereate the docs in ``doc/html/pyunbound``, which can be browsed in a webbrowser by opening ``index.html``.

Another option of gereating the files is available if you are using :command:`sphinx`.

.. code:: bash

    sphinx-build -b html libunbound/python/doc doc/html/pyunbound/

Pythonmod
*********

Unbound also contains a module that executes python code called "pythonmod". The supplied Python code has to follow module operation semantics. This module is enabled in the :command:`configure` step of the installation using the following command.

./configure --with-pythonmodule

The full documentation for it can be build using:

We can then generate the documentation for this using:

.. code:: bash

    make doc

This command will genereate the docs in ``doc/html/pythonmod``, which can be browsed in a webbrowser by opening ``index.html``. 

Another option of gereating the files is available if you are using :command:`sphinx`.

.. code:: bash

    sphinx-build -b html pythonmod/doc/ doc/html/pythonmod/
