# Next version

# Roadmap v.0.10

* 0.01 DRV Carp/croak/confess backend for bona-fide assertions
* 0.01 TST Need to add examples
* 0.02 MOD Module to check that "foo" is really implementation of "bar"
* 0.03 BLD Prohibit `my_*`, `get_*`, `do_*`, `set_*` as test names

# Backlog v.0.20

* 0.03 MOD Round-trip assertion
* 0.01 API plan tests => nnn
* 0.01 DRV Own Unit-testing backend
* 0.02 API Short-circuit - just fail, don't conduct the whole set.
* 0.02 API Some extra goodies to contract {...} like title

# Backlog v.0.30+

* 0.02 API `bail_out` to stop tests altogether

# Need to think harder

* 0.01 API Proper subcontract implementation with indented log

# THIS FILE FORMAT

This file is a list of features/bugs to be added to this distribution:

* {version appeared} {TAG} Feature/bug description

Please try to avoid committing it between releases,
altering the file is fine though.

# TAG LIST

Please prepend the following tags to tasks as well as commit messages.
Adding new tags to this list is ok, too.

* **API** - extending API
* **DRV** - adding new backends (drivers)
* **BLD** - test builder features/bugs
* **REF** - refactoring, internat structure changes, optimisations
* **DOC** - improving documentation, use case descriptions
* **TST** - adding tests/examples
* **BUG** - bugfix
* **AUX** - changing distribution files
