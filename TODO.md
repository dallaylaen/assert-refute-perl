# Next version

# Roadmap v.0.10

* 0.07 DRV Test::More: Consistent reporting of caller under T::M
* 0.01 API plan tests => nnn

# Backlog v.0.20

* 0.05 MOD Util::Tempfile - preserve file if tests fail
* 0.05 API Make sugar for `A::R::Exec->new->do_run`
* 0.01 DRV Own Unit-testing backend
* 0.07 API verbosity switch to include more/less info in report
* 0.07 MOD T::Array: block subs curry if no second arg
* 0.02 API `bail_out` to stop tests altogether

# Backlog v.0.30+

* 0.02 API Short-circuit - just fail, don't conduct the whole set.
* 0.03 REF Decouple Exec class into Report + Driver
* 0.03 DRV A TAP consumer class
* 0.05 MOD T::Array: point misbehaving elements in all tests
* 0.05 API Exec: configurable verbosity level
* 0.05 MOD Provide what Test::Most can
* 0.03 MOD Round-trip assertion
* 0.05 TST Even more examples
* 0.02 API Some extra goodies to contract {...} like title
* 0.05 MOD `is_unique` - make a string unique within current contract
* 0.07 MOD `is_diff` LCS-based multiline test
* 0.07 MOD Saner `is_deeply` and `to_scalar` format
* 0.07 API If contract with args fails, display args
* 0.07 MOD Spanshot assertion

# Need to think harder

* 0.01 API Proper subcontract implementation with indented log
* 0.02 MOD Module to check that "foo" is really implementation of "bar"
* 0.07 API one-line abbreviated log-friendly report
* 0.07 API "the above test is essential" mark to trigger a harder degree of fail
* 0.07 API Do something with contract
* 0.07 API $TODO to "pass" failing tests

# THIS FILE FORMAT

This file is a list of features/bugs to be added to this distribution:

* {version appeared} {TAG} Feature/bug description

Please try to avoid committing it between releases,
altering the file is fine though.

# TAG LIST

Please prepend the following tags to tasks as well as commit messages.
Adding new tags to this list is ok, too.

* **API** - extending API
* **MOD** - new test conditions
* **DRV** - adding new backends (drivers)
* **BLD** - test builder features/bugs
* **REF** - refactoring, internat structure changes, optimisations
* **DOC** - improving documentation, use case descriptions
* **TST** - adding tests/examples
* **BUG** - bugfix
* **AUX** - changing distribution files (Makefile, README, xt tests etc)
