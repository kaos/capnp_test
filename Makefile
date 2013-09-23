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
CAPNP_TEST_APP ?= $(error CAPNP_TEST_APP was not defined)

# List of test cases to run; defaults to all known tests
TESTS ?= $(ALL_TESTS)

# What to test in each case
TEST_FLAVORS ?= decode encode

ALL_TESTS = $(shell \
	capnp eval --short test.capnp allTests \
	| sed 's/\[*"\([^"]*\)",*\]*/\1 /g')

PREP_TESTS = $(addprefix prepare_test_data-,$(TESTS))
RUN_TESTS =  $(foreach case,$(TEST_FLAVORS),$(addprefix $(case)-,$(TESTS)))

test_type = $(shell capnp eval test.capnp $(1)Type | sed 's/"//g')

all: $(PREP_TESTS) $(RUN_TESTS)
	echo "$(CAPNP_TEST_APP) done."

start-%:
	printf "++ TEST [%s]\n" $*

prepare_test_data-%: test.capnp expect
	capnp eval --short $< $* > expect/$*.txt
	capnp eval --binary $< $* > expect/$*.bin

expect:
	mkdir $@

decode-%: start-decode-%
	( cat expect/$*.bin \
	| $(CAPNP_TEST_APP) decode $* \
	| diff expect/$*.txt - \
	&& printf "== PASS [%s]\n\n" $@) \
	|| printf "## FAIL [%s]\n\n" $@

encode-%: start-encode-%
	( $(CAPNP_TEST_APP) encode $* \
	| capnp decode --short test.capnp $(call test_type,$*)\
	| diff expect/$*.txt - \
	&& printf "== PASS [%s]\n\n" $@) \
	|| printf "## FAIL [%s]\n\n" $@
