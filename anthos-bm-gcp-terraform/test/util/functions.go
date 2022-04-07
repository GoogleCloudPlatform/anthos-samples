// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package util

import (
	"bufio"
	"log"
	"os"
)

// LogError takes in an error returned from a function call and a string message;
// Prints the message on the error object along with the string message.
// Calling this method causes the progrma to exit
func LogError(err error, errMsg string) {
	if err != nil {
		log.Fatalf("%s:\n\t%s", errMsg, err)
	}
}

// ExitIf checks two variables are same, given a boolean variable and its
// expected state; if they match, then the exit condition is met. Thus, an
// error message is logged and th eprogram exists
func ExitIf(varToCheck bool, expectedState bool) {
	if varToCheck == expectedState {
		var err error
		LogError(err, "Exiting tests since failute condition met.")
	}
}

// WriteToFile creates a new file at the path denoted by the second arguments
// and writes the string to the newly created file, accessible on that path
func WriteToFile(s string, path string) {
	f, _ := os.Create(path)
	w := bufio.NewWriter(f)
	w.WriteString(s)
	w.Flush()
}
