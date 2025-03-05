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
const standardSolutionTerraformDir = "solutions/fully-configurable"

// Current supported regions for watsonx.ai Studio, Runtime and IBM watsonx platform (dataplatform.ibm.com)
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
	options.TerraformVars = map[string]interface{}{
		"region":         validRegions[rand.Intn(len(validRegions))],
		"prefix":         options.Prefix,
		"resource_group": resourceGroup,
		"resource_tags":  options.Tags,
	}
	return options
}

// Provision KMS - Key Protect to use in DA tests
func setupKMSKeyProtect(t *testing.T, region string, prefix string) *terraform.Options {
	realTerraformDir := "./resources/kp-instance"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))

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
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	require.NoError(t, existErr, "Init and Apply of temp resources (KP Instance and Key creation) failed")

	return existingTerraformOptions
}

// Cleanup the resources when KMS encryption key is created.
func cleanupResources(t *testing.T, terraformOptions *terraform.Options, prefix string) {
	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, terraformOptions)
		terraform.WorkspaceDelete(t, terraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "wxai-basic", basicExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "wxai-complete", completeExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

// Test the DA
func TestRunStandardSolution(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]
	prefixKMSKey := fmt.Sprintf("wxai-da-%s", strings.ToLower(random.UniqueId()))
	existingTerraformOptions := setupKMSKeyProtect(t, region, prefixKMSKey)

	// Deploy watsonx.ai DA using existing KP details
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  standardSolutionTerraformDir,
		Prefix:        "wxai-da",
		Region:        region,
		ResourceGroup: resourceGroup,
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
	})
	options.TerraformVars = map[string]interface{}{
		"prefix":                       options.Prefix,
		"region":                       options.Region,
		"existing_resource_group_name": resourceGroup,
		"resource_group_name":          terraform.Output(t, existingTerraformOptions, "resource_group_name"),
		"provider_visibility":          "public",
		"watsonx_ai_project_name":      "wxai-da-prj",
		"existing_kms_instance_crn":    terraform.Output(t, existingTerraformOptions, "key_protect_crn"),
		"kms_endpoint_type":            "public",
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")

	cleanupResources(t, existingTerraformOptions, prefixKMSKey)
}

func TestRunStandardUpgradeSolution(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]
	prefixKMSKey := fmt.Sprintf("wxai-da-%s", strings.ToLower(random.UniqueId()))
	existingTerraformOptions := setupKMSKeyProtect(t, region, prefixKMSKey)

	// Deploy watsonx.ai DA using existing KP details
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  standardSolutionTerraformDir,
		Prefix:        "wxai-da-upg",
		Region:        region,
		ResourceGroup: resourceGroup,
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
	})
	options.TerraformVars = map[string]interface{}{
		"prefix":                       options.Prefix,
		"region":                       options.Region,
		"existing_resource_group_name": resourceGroup,
		"resource_group_name":          terraform.Output(t, existingTerraformOptions, "resource_group_name"),
		"provider_visibility":          "public",
		"watsonx_ai_project_name":      "wxai-ug-prj",
		"existing_kms_instance_crn":    terraform.Output(t, existingTerraformOptions, "key_protect_crn"),
	}

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}

	cleanupResources(t, existingTerraformOptions, prefixKMSKey)
}
