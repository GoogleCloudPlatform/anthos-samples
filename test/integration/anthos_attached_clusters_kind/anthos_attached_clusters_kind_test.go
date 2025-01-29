// Copyright 2024 Google LLC
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

package aackind

import (
	"fmt"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/stretchr/testify/assert"
)

const deploymentName = "istiod-asm-1227-4"

func TestAACKind(t *testing.T) {
	kind := tft.NewTFBlueprintTest(t)

	kind.DefineVerify(func(assert *assert.Assertions) {
		kind.DefaultVerify(assert)

		k8sOptions := k8s.NewKubectlOptions(
			kind.GetStringOutput("context"),
			kind.GetStringOutput("kubeconfig"),
			"istio-system",
		)

		command := func() (string, error) {
			deployment, err := k8s.GetDeploymentE(t, k8sOptions, deploymentName)
			if err != nil {
				return "", err
			}
			return deployment.Name, nil
		}

		output := retry.DoWithRetry(
			t,
			fmt.Sprintf("Get `%s` deployment", deploymentName),
			10,
			time.Duration(30) * time.Second,
			command,
		)

		assert.Equal(output, deploymentName, fmt.Sprintf("cluster should have deployment %s", deploymentName))
	})

	kind.Test()
}
