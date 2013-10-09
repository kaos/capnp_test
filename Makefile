#   Copyright 2013 Andreas Stenius <kaos@astekk.se>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# This should be defined by the invoking environment, pointing to the
# executable that will perform the requested test actions.
# Exit code of 127 is regarded as a skip test request..
CAPNP_TEST_APP ?= $(error CAPNP_TEST_APP was not defined)

# List of test cases to run; defaults to all known tests
TESTS ?= $(ALL_TESTS)

# What to test in each case
TEST_FLAVORS ?= decode encode

ALL_TESTS = $(shell \
	capnp eval --short test.capnp allTests \
	| sed 's/\[*"\([^"]*\)",*\]*/\1 /g')

EXPECT_FILES = $(foreach test,$(TESTS),$(addprefix expect/$(test),.txt .bin))
RUN_TESTS =  $(foreach case,$(TEST_FLAVORS),\
	$(foreach test,$(TESTS),"$(case) $(test) $(call test_type,$(test))"))

test_type = $(shell capnp eval test.capnp $(1)Type | sed 's/"//g')

EXEC_TEST = ./exec_test.sh

.PHONY: all clean

all: $(CAPNP_TEST_APP) $(EXPECT_FILES)
	@(tot=0;pass=0;skip=0; \
		for test in $(RUN_TESTS); do \
			(( tot += 1 )) ; \
			$(EXEC_TEST) $$test ; \
			case $$? in \
				0)   (( pass += 1 )) ;; \
				127) (( skip += 1 )) ; \
			esac ; \
		done ; \
		(( tot -= skip )) ; \
		echo "$(CAPNP_TEST_APP): $$pass/$$tot tests passsed ($$skip skipped).")

clean:
	rm -rf expect

expect/%.txt: test.capnp | expect
	capnp eval --short $< $* > $@

expect/%.bin: test.capnp | expect
	capnp eval --binary $< $* > $@

expect:
	mkdir $@
