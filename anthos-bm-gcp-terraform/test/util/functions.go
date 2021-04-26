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

	"google.golang.org/api/compute/v1"
	"google.golang.org/api/googleapi"
)

type GcpOperation interface {
	Do(opts ...googleapi.CallOption) (*compute.Operation, error)
}

func DeleteResource(fn GcpOperation, errMsg string) {
	_, err := fn.Do()
	LogError(err, errMsg)
}

func LogError(err error, errMsg string) {
	if err != nil {
		log.Fatalf("%s:\n\t%s", errMsg, err)
	}
}

func ExitIf(varToCheck bool, expectedState bool) {
	if varToCheck == expectedState {
		var err error
		LogError(err, "Exiting tests since failute condition met.")
	}
}

func WriteToFile(s string, path string) {
	f, _ := os.Create(path)
	w := bufio.NewWriter(f)
	w.WriteString(s)
	w.Flush()
}
