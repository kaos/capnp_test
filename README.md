capnp_test
==========

Test framework for Cap'n Proto plugins.

The idea is to have a language agnostic test framework for Cap'n Proto
plugins to use. This way there is a common set of tests to maintain
that can be used by any plugin in any language.

At the core is a `test.capnp` schema defining all test data, and a
`Makefile` for invoking the PUT (plugin under test) with data from the
test schema.


Integrating the test framework with your plugin
===============================================

A single executable, referred to as `CAPNP_TEST_APP` in the
`Makefile`, is responsible for that each test gets carried out. That
is, `CAPNP_TEST_APP` is called once, for each test case, with two
arguments: the operation to be performed, and the name of the data
from `test.capnp`. So, some knowledge of the relation between the name
of the test data its type may be needed by the test app.

In order to run the test suite, invoke `make` with CAPNP_TEST_APP
defined to the test app to use.

This may look something like this, when run from a command prompt:

```
    make CAPNP_TEST_APP=/path/to/test_app
```

If invoked from another makefile, simply make sure to export the
`CAPNP_TEST_APP` variable, and then call `$(MAKE) -C
/path/to/capnp_test`.


Test cases
==========

The test cases is based on coding and decoding messages of varying
types and data. All of this is defined in `test.capnp` and referenced
from the `Makefile`.

In order to run a subset of the tests, define `TESTS` to the list of
tests to be run prior to invoking `make`.


Example
=======

As an example, we can look at the part of the `Makefile` for
[ecapnp](http://github.com/kaos/ecapnp) that defines the rules for
invoking the capnp_test tests.

```
check: export CAPNP_TEST_APP = $(CURDIR)/bin/ecapnp_test
check: test-schema build-test-deps

test-schema: $(DEPS_DIR)/capnp_test bin/test.capnp.hrl

bin/test.capnp.hrl: $(DEPS_DIR)/capnp_test/test.capnp
	capnpc -oerl:$(dir $@) --src-prefix=$(dir $<) $<
```

The `build-test-deps` target simply invokes a `make all` in the directory of
`ecapnp_test`.


What does it look like?
-----------------------

When run, it may look something like this:

```
kaos@cypher ~/src/ecapnp (master *)
$ make check
++ TEST [decode-simpleTest]
== PASS [decode-simpleTest]

/home/kaos/src/ecapnp/bin/ecapnp_test done.
```

Or, in case of errors:

```
kaos@cypher ~/src/ecapnp (master *)
$ make check
++ TEST [decode-simpleTest]
2c2
<   msg = "a short message..." )
---
>   msg = "...egassem trohs a" )
## FAIL [decode-simpleTest]

/home/kaos/src/ecapnp/bin/ecapnp_test done.
```


TODO
====

More tests. Test different packaging/streaming options. Default values. Etc..


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/kaos/capnp_test/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

