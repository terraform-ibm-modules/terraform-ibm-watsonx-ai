<!-- Update this title with a descriptive name. Use sentence case. -->
# IBM watsonx.ai module

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-watsonx-ai?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-watsonx-ai/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-623CE4?logo=terraform)](https://registry.terraform.io/modules/terraform-ibm-modules/watsonx-ai/ibm/latest)

<!--
Add a description of modules in this repo.
Expand on the repo short description in the .github/settings.yml file.

For information, see "Module names and descriptions" at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=module-names-and-descriptions
-->

IBM `watsonx.ai` provides an enterprise-grade studio of integrated tools for developing AI services and deploying them into your applications of choice. Refer [here](https://dataplatform.cloud.ibm.com/docs/content/wsj/getting-started/overview-wx.html?context=wx&audience=wdp#watsonxai) for more information on `watsonx.ai`.

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-watsonx-ai](#terraform-ibm-watsonx-ai)
* [Submodules](./modules)
    * [configure_project](./modules/configure_project)
    * [configure_user](./modules/configure_user)
    * [storage_delegation](./modules/storage_delegation)
* [Examples](./examples)
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
    * <a href="./examples/basic">Basic example</a> <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=watsonx-ai-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-watsonx-ai/tree/main/examples/basic"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
    * <a href="./examples/complete">Complete example</a> <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=watsonx-ai-complete-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-watsonx-ai/tree/main/examples/complete"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
* [Deployable Architectures](./solutions)
    * <a href="./solutions/fully-configurable">Cloud automation for watsonx.ai (Fully configurable)</a>
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and link to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-watsonx-ai

This module supports the following:

* Provisions the following services:
    * `watsonx.ai Studio` (formerly known as `Watson Studio`)
    * `watsonx.ai Runtime` (formerly known as `Watson Machine Learning`)
* Configures the IBM `watsonx.ai` user profile for an existing IBM Cloud user. This user is also referred as IBM `watsonx.ai` admin.
* Enables storage delegation for the `Cloud Object Storage` instance when `KMS` encryption is enabled.
* Creates a starter `watsonx.ai` project.

### Usage

```hcl

module "watsonx_ai" {
  source                        = "terraform-ibm-modules/watsonx-ai/ibm"
  version                       = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  region                        = "us-south"
  resource_tags                 = ["tag1", "tag2"]
  resource_group_id             = "xxXXx...X" # replace with ID of the resource group
  watsonx_ai_studio_plan        = "free-v1"
  watsonx_ai_runtime_plan       = "lite"
  project_name                  = "my-project"
  enable_cos_kms_encryption     = true
  cos_instance_crn              = "xxXXx...X" # replace with CRN of the COS instance
  cos_kms_key_crn               = "xxXXx...X" # replace with CRN of KMS key
}

```

### Required access policies

You need the following permissions to run this module:

- Account Management
    - **Resource group**
        - `Viewer` access on the specific resource group
- IAM services
    - **watsonx.ai Runtime** service
        - `Editor` platform access
    - **watsonx.ai Studio** service
        - `Editor` platform access
    - **Cloud Object Storage** service
        - `Editor` platform access
        - `Manager` service access

> Note: If you are not the IBM Cloud account owner, then the addition of the policy `All Account Management Services` with role `Administrator` is required for storage delegation. To add the required access, go to:
`IBM Cloud -> Manage -> Access (IAM) -> Users -> {USER} -> Access -> Access Policies`


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.70.1, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_configure_project"></a> [configure\_project](#module\_configure\_project) | ./modules/configure_project | n/a |
| <a name="module_configure_user"></a> [configure\_user](#module\_configure\_user) | ./modules/configure_user | n/a |
| <a name="module_cos_crn_parser"></a> [cos\_crn\_parser](#module\_cos\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.4.2 |
| <a name="module_cos_kms_key_crn_parser"></a> [cos\_kms\_key\_crn\_parser](#module\_cos\_kms\_key\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.4.2 |
| <a name="module_storage_delegation"></a> [storage\_delegation](#module\_storage\_delegation) | ./modules/storage_delegation | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_resource_instance.watsonx_ai_runtime_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.watsonx_ai_studio_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.existing_watsonx_ai_runtime_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |
| [ibm_resource_instance.existing_watsonx_ai_studio_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cos_instance_crn"></a> [cos\_instance\_crn](#input\_cos\_instance\_crn) | The CRN of the Object Storage instance. | `string` | n/a | yes |
| <a name="input_cos_kms_key_crn"></a> [cos\_kms\_key\_crn](#input\_cos\_kms\_key\_crn) | The CRN of a Key Protect key. This key is used to encrypt the Object Storage buckets used by watsonx.ai. | `string` | `null` | no |
| <a name="input_create_watsonx_ai_project"></a> [create\_watsonx\_ai\_project](#input\_create\_watsonx\_ai\_project) | Whether to create and configure a starter watsonx.ai project. | `bool` | `true` | no |
| <a name="input_enable_cos_kms_encryption"></a> [enable\_cos\_kms\_encryption](#input\_enable\_cos\_kms\_encryption) | Flag to enable Object Storage key encryption. If set to `true`, a value must be passed for `cos_kms_key_crn`. | `bool` | `false` | no |
| <a name="input_existing_watsonx_ai_runtime_instance_crn"></a> [existing\_watsonx\_ai\_runtime\_instance\_crn](#input\_existing\_watsonx\_ai\_runtime\_instance\_crn) | The CRN of an existing watsonx.ai Runtime instance. If not provided, a new instance is provisioned. | `string` | `null` | no |
| <a name="input_existing_watsonx_ai_studio_instance_crn"></a> [existing\_watsonx\_ai\_studio\_instance\_crn](#input\_existing\_watsonx\_ai\_studio\_instance\_crn) | The CRN of an existing watsonx.ai Studio instance. If not provided, a new instance is provisioned. | `string` | `null` | no |
| <a name="input_mark_as_sensitive"></a> [mark\_as\_sensitive](#input\_mark\_as\_sensitive) | Set to `true` to create the watsonx.ai project with the `Mark as sensitive` flag enabled. The flag enforces access restrictions and prevents data from being moved out of the project. | `bool` | `false` | no |
| <a name="input_project_description"></a> [project\_description](#input\_project\_description) | A description of the watsonx.ai project that is created. | `string` | `"Watsonx.ai project created by the watsonx.ai module."` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the watsonx.ai project. | `string` | `"demo"` | no |
| <a name="input_project_tags"></a> [project\_tags](#input\_project\_tags) | A list of tags associated with the watsonx.ai project. Each tag consists of a string containing up to 255 characters. These tags can include spaces, letters, numbers, underscores, dashes, as well as the symbols `#` and `@`. | `list(string)` | <pre>[<br/>  "watsonx-ai"<br/>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the watsonx.ai instance is provisioned. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID for the watsonx.ai instance. Required to create an instance of watsonx.ai. | `string` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to describe the watsonx.ai instance. | `list(string)` | `[]` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the key management service instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to not create this policy. | `bool` | `false` | no |
| <a name="input_watsonx_ai_new_project_members"></a> [watsonx\_ai\_new\_project\_members](#input\_watsonx\_ai\_new\_project\_members) | The list of members to add to the watsonx.ai project. | <pre>list(object({<br/>    email  = string<br/>    iam_id = string<br/>    role   = string<br/>    state  = optional(string, "ACTIVE")<br/>    type   = optional(string, "user")<br/>    })<br/>  )</pre> | `[]` | no |
| <a name="input_watsonx_ai_runtime_instance_name"></a> [watsonx\_ai\_runtime\_instance\_name](#input\_watsonx\_ai\_runtime\_instance\_name) | The name of the watsonx.ai Runtime instance to create. If a prefix input variable is passed, it is prefixed to the value following a `<prefix>-value` format. | `string` | `"watsonx-runtime"` | no |
| <a name="input_watsonx_ai_runtime_plan"></a> [watsonx\_ai\_runtime\_plan](#input\_watsonx\_ai\_runtime\_plan) | The plan that is used to provision the watsonx.ai Runtime instance. Allowed values are 'lite', 'v2-professional', and 'v2-standard'. 'lite' refers to the 'Lite' plan, 'v2-professional' refers to the 'Standard' plan, and 'v2-standard' refers to the 'Essentials' plan on the IBM Cloud dashboard. For 'lite' plan, the `watsonx_ai_runtime_service_endpoints` value is ignored and the default service configuration is applied. | `string` | `"lite"` | no |
| <a name="input_watsonx_ai_runtime_service_endpoints"></a> [watsonx\_ai\_runtime\_service\_endpoints](#input\_watsonx\_ai\_runtime\_service\_endpoints) | The type of service endpoints for watsonx.ai Runtime. Possible values are 'public', 'private', or 'public-and-private'. | `string` | `"public"` | no |
| <a name="input_watsonx_ai_studio_instance_name"></a> [watsonx\_ai\_studio\_instance\_name](#input\_watsonx\_ai\_studio\_instance\_name) | The name of the watsonx.ai Studio instance to create. If a prefix input variable is passed, it is prefixed to the value following a `<prefix>-value` format. | `string` | `"watsonx-studio"` | no |
| <a name="input_watsonx_ai_studio_plan"></a> [watsonx\_ai\_studio\_plan](#input\_watsonx\_ai\_studio\_plan) | The plan that is used to provision the watsonx.ai Studio instance. Allowed values are 'free-v1' and 'professional-v1'. 'free-v1' refers to the 'Lite' plan and 'professional-v1' refers to the 'Professional' plan on IBM Cloud dashboard. | `string` | `"free-v1"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_watsonx_ai_project_bucket_name"></a> [watsonx\_ai\_project\_bucket\_name](#output\_watsonx\_ai\_project\_bucket\_name) | The name of the Object Storage bucket created for the watsonx.ai project. |
| <a name="output_watsonx_ai_project_id"></a> [watsonx\_ai\_project\_id](#output\_watsonx\_ai\_project\_id) | The ID of the watsonx.ai project that is created. |
| <a name="output_watsonx_ai_project_url"></a> [watsonx\_ai\_project\_url](#output\_watsonx\_ai\_project\_url) | The URL of the watsonx.ai project that is created. |
| <a name="output_watsonx_ai_runtime_account_id"></a> [watsonx\_ai\_runtime\_account\_id](#output\_watsonx\_ai\_runtime\_account\_id) | The account ID of the watsonx.ai Runtime instance. |
| <a name="output_watsonx_ai_runtime_crn"></a> [watsonx\_ai\_runtime\_crn](#output\_watsonx\_ai\_runtime\_crn) | The CRN of the watsonx.ai Runtime instance. |
| <a name="output_watsonx_ai_runtime_dashboard_url"></a> [watsonx\_ai\_runtime\_dashboard\_url](#output\_watsonx\_ai\_runtime\_dashboard\_url) | The dashboard URL of the watsonx.ai Runtime instance. |
| <a name="output_watsonx_ai_runtime_guid"></a> [watsonx\_ai\_runtime\_guid](#output\_watsonx\_ai\_runtime\_guid) | The GUID of the watsonx.ai Runtime instance. |
| <a name="output_watsonx_ai_runtime_name"></a> [watsonx\_ai\_runtime\_name](#output\_watsonx\_ai\_runtime\_name) | The name of the watsonx.ai Runtime instance. |
| <a name="output_watsonx_ai_runtime_plan_id"></a> [watsonx\_ai\_runtime\_plan\_id](#output\_watsonx\_ai\_runtime\_plan\_id) | The plan ID of the watsonx.ai Runtime instance. |
| <a name="output_watsonx_ai_studio_crn"></a> [watsonx\_ai\_studio\_crn](#output\_watsonx\_ai\_studio\_crn) | The CRN of the watsonx.ai Studio instance. |
| <a name="output_watsonx_ai_studio_dashboard_url"></a> [watsonx\_ai\_studio\_dashboard\_url](#output\_watsonx\_ai\_studio\_dashboard\_url) | The dashboard URL of the watsonx.ai Studio instance. |
| <a name="output_watsonx_ai_studio_guid"></a> [watsonx\_ai\_studio\_guid](#output\_watsonx\_ai\_studio\_guid) | The GUID of the watsonx.ai Studio instance. |
| <a name="output_watsonx_ai_studio_name"></a> [watsonx\_ai\_studio\_name](#output\_watsonx\_ai\_studio\_name) | The name of the watsonx.ai Studio instance. |
| <a name="output_watsonx_ai_studio_plan_id"></a> [watsonx\_ai\_studio\_plan\_id](#output\_watsonx\_ai\_studio\_plan\_id) | The plan ID of the watsonx.ai Studio instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
