// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"strings"
	"testing"

	"github.com/IBM/go-sdk-core/core"
	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic"
const completeExampleDir = "examples/complete"
const fullyConfigurableSolutionTerraformDir = "solutions/fully-configurable"
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"
const terraformVersion = "terraform_v1.10" // This should match the version in the ibm_catalog.json

// Current supported regions for watsonx.ai Studio, Runtime and IBM watsonx platform (dataplatform.ibm.com)
var validRegions = []string{
	"us-south",
	"eu-de",
	"eu-gb",
	"jp-tok",
}

var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
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
	realTerraformDir := "./resources/kp-cos-instance"
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

func setupFullyConfigurableOptions(t *testing.T, prefix string) *testschematic.TestSchematicOptions {
	var region = validRegions[rand.Intn(len(validRegions))]
	prefixExistingRes := fmt.Sprintf("wxai-da-%s", strings.ToLower(random.UniqueId()))
	existingTerraformOptions := setupKMSKeyProtect(t, region, prefixExistingRes)

	// Deploy watsonx.ai DA using existing KP details
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:        t,
		TemplateFolder: fullyConfigurableSolutionTerraformDir,
		Prefix:         "wxai-upg",
		Region:         region,
		ResourceGroup:  resourceGroup,
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
		TerraformVersion: terraformVersion,
	})
	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "provider_visibility", Value: "private", DataType: "string"},
		{Name: "watsonx_ai_project_name", Value: "wxai-ug-prj", DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "key_protect_crn"), DataType: "string"},
		{Name: "kms_endpoint_type", Value: "private", DataType: "string"},
		{Name: "existing_cos_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "cos_crn"), DataType: "string"},
		{Name: "enable_cos_kms_encryption", Value: true, DataType: "string"},
	}
	return options
}

// Test the DA
func TestRunFullyConfigurableSolutionSchematics(t *testing.T) {
	t.Parallel()

	options := setupFullyConfigurableOptions(t, "wxai")

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunFullyConfigurableUpgradeSolutionSchematics(t *testing.T) {
	t.Parallel()

	options := setupFullyConfigurableOptions(t, "wxai-up")
	options.CheckApplyResultForUpgrade = true

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

func TestWatsonxaiDefaultConfiguration(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "ai-def",
		ResourceGroup: resourceGroup,
		QuietMode:     true, // Suppress logs except on failure
	})
	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-ibm-watsonx-ai",
		"fully-configurable",
		map[string]interface{}{
			"prefix":                       options.Prefix,
			"existing_resource_group_name": resourceGroup,
		},
	)

	// Disable target / route creation to prevent hitting quota in account
	options.AddonConfig.Dependencies = []cloudinfo.AddonConfig{
		{
			OfferingName:   "deploy-arch-ibm-cloud-monitoring",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_metrics_routing_to_cloud_monitoring": false,
			},
			Enabled: core.BoolPtr(true),
		},
		{
			OfferingName:   "deploy-arch-ibm-activity-tracker",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_activity_tracker_event_routing_to_cloud_logs": false,
			},
			Enabled: core.BoolPtr(true),
		},
	}

	err := options.RunAddonTest()
	require.NoError(t, err)
}
