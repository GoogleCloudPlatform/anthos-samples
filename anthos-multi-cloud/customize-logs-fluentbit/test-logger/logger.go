// Copyright 2022 Google LLC
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

package main

/*
 * Implements a simple program that outputs a random log statement at a regular interval.
 */
import (
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"time"
)

var logStatements = [4]string{
	"error happened with social security number 111-22-3333",
	"Something happened..with social 222-33-4444",
	"Processing credit card 1234 5678 9012 3456",
	"Users email is john.doe@example.com"}

//Convert a string to an int, but consume any error and use the default instead.
func convertToInt(s string, def int) int {
	var result, err = strconv.Atoi(s)
	fmt.Println(result)
	if err != nil {
		fmt.Println(err)
		result = def
	}
	return result
}

//Get a random log statement
func getLogInfo() string {
	return logStatements[rand.Intn(4)]
}

//Output the log statement
func logInfo(header string) {
	fmt.Println(header + getLogInfo())
}

// Kickoff a timed logger with random messages.
func startLogEvents(timeInterval int, header string) {
	for true {
		time.Sleep(time.Duration(timeInterval) * time.Second)
		logInfo(header)
	}
}
func main() {
	rand.Seed(time.Now().UTC().UnixNano())
	// Take the log interval and logging header from the environment
	logInterval := convertToInt(os.Getenv("LOG_INTERVAL"), 2)
	header := os.Getenv("HEADER")
	whenToStart := rand.Intn(10)
	time.Sleep(time.Duration(whenToStart) * time.Second)
	startLogEvents(logInterval, header)
}
