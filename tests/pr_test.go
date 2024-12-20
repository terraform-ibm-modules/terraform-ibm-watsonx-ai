// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"math/rand"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic"
const completeExampleDir = "examples/complete"

// Current supported regions for watsonx Studio, Runtime and IBM watsonx platform (dataplatform.ibm.com)
var validRegions = []string{
	"us-south",
	"eu-de",
	"eu-gb",
	"jp-tok",
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,

		IgnoreDestroys: testhelper.Exemptions{ // Ignore for consistency check
			List: []string{
				"module.watsonx_ai.module.configure_user.null_resource.configure_user",
				"module.watsonx_ai.module.configure_user.null_resource.restrict_access",
			},
		},
		IgnoreUpdates: testhelper.Exemptions{ // Ignore for consistency check
			List: []string{
				"module.watsonx_ai.module.configure_user.null_resource.configure_user",
				"module.watsonx_ai.module.configure_user.null_resource.restrict_access",
			},
		},

		TerraformVars: map[string]interface{}{
			"region":         validRegions[rand.Intn(len(validRegions))],
			"resource_group": resourceGroup,
		},
	})
	return options
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "wx-basic", basicExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "wx-complete", completeExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "wx-ai-upg", completeExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
