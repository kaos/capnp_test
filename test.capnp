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

@0xa510a585dee47e0b;

using Cxx = import "/capnp/c++.capnp";
$Cxx.namespace("capnp_test");


########################################
## List with all available tests
########################################

const allTests :List(Text) = 
[
  "simpleTest",
  "textListTypeTest"
];


########################################
## Define test data
########################################

const simpleTestType :Text = "SimpleTest";
const simpleTest :SimpleTest = (int = 1234567890, msg = "a short message...");

const textListTypeTestType :Text = "ListTest";
const textListTypeTest :ListTest = (textList = ["foo", "bar", "baz"]);


########################################
## Types used by tests
########################################

struct SimpleTest {
  int @0 :Int32;
  msg @1 :Text;
}

struct ListTest {
#  union {
    textList @0 :List(Text);
#   nextList @1 :...;
#  }
}
