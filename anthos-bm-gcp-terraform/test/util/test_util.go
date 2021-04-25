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
		os.Exit(1)
	}
}

func WriteToFile(s string, path string) {
	f, _ := os.Create(path)
	w := bufio.NewWriter(f)
	w.WriteString(s)
	w.Flush()
}
