// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"math/rand"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic"
const completeExampleDir = "examples/complete"
const standardSolutionTerraformDir = "solutions/standard"

// const subModuleConfigureProjectTerraformDir = "modules/configure_project"
// const subModuleConfigureUserTerraformDir = "modules/configure_user"
// const subModuleConfigureUserScriptsDir = "modules/configure_user/scripts"
// const subModuleStorageDelegationTerraformDir = "modules/storage_delegation"

// Current supported regions for watsonx.ai Studio, Runtime and IBM watsonx platform (dataplatform.ibm.com)
var validRegions = []string{
	"us-south",
	// "eu-de",
	// "eu-gb",
	// "jp-tok",
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

	options := setupOptions(t, "wx-ai-basic", basicExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "wx-ai-complete", completeExampleDir)

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

// Test the DA
func TestRunStandardSolution(t *testing.T) {
	t.Parallel()

	// ---------------------------------------------------------
	// Provision KMS - Key Protect
	// ---------------------------------------------------------

	var region = validRegions[rand.Intn(len(validRegions))]

	prefix := "wx-da"
	realTerraformDir := "./resources/kp-instance"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix": prefix,
			"region": region,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)

	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp resources (KP Instance and Key creation) failed")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy watsonx.ai DA using existing KP details
		// ------------------------------------------------------------------------------------

		options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
			Testing:      t,
			TerraformDir: standardSolutionTerraformDir,
			Prefix:       "wx-da",
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
				"region":                      validRegions[rand.Intn(len(validRegions))],
				"use_existing_resource_group": true,
				"resource_group_name":         terraform.Output(t, existingTerraformOptions, "resource_group_name"),
				"provider_visibility":         "public",
				"watsonx_ai_project_name":     "wx-da-prj",
				"existing_kms_instance_crn":   terraform.Output(t, existingTerraformOptions, "key_protect_crn"),
			},
		})

		output, err := options.RunTestConsistency()
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}

	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary resources created
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, existingTerraformOptions)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}
