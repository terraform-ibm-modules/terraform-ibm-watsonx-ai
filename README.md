<!-- Update this title with a descriptive name. Use sentence case. -->
# IBM watsonx.ai module

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-watsonx-ai?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-watsonx-ai/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!--
Add a description of modules in this repo.
Expand on the repo short description in the .github/settings.yml file.

For information, see "Module names and descriptions" at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=module-names-and-descriptions
-->

IBM watsonx.ai provides an enterprise-grade studio of integrated tools for developing AI services and deploying them into your applications of choice. Refer [here](https://dataplatform.cloud.ibm.com/docs/content/wsj/getting-started/overview-wx.html?context=wx&audience=wdp#watsonxai) for more information on watsonx.ai.

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-watsonx-ai](#terraform-ibm-watsonx-ai)
* [Submodules](./modules)
    * [configure_project](./modules/configure_project)
    * [configure_user](./modules/configure_user)
    * [storage_delegation](./modules/storage_delegation)
* [Examples](./examples)
    * [Basic example](./examples/basic)
    * [Complete example](./examples/complete)
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
    * watsonx.ai Studio (formerly known as Watson Studio)
    * watsonx.ai Runtime (formerly known as Watson Machine Learning)
* Configures the IBM watsonx user profile for an existing IBM Cloud user. This user is also referred as IBM watsonx admin.
* Enables storage delegation for the Cloud Object Storage instance when KMS encryption is enabled.
* Creates a starter `watsonx.ai` project.

### Usage

```hcl

module "watsonx_ai" {
  source                        = "terraform-ibm-modules/watsonx-ai/ibm"
  prefix                        = "watsonx"
  region                        = "us-south"
  resource_tags                 = []
  resource_group_id             = "a8csdsfdg8230a"
  watson_studio_plan            = "professional-v1"
  watson_machine_learning_plan  = "v2-professional"
  watsonx_project_name          = "watsonx-project"
  enable_cos_kms_encryption     = true
  cos_instance_crn              = "crn:v1:bluemix:public:cloud-object-storage:global:a/abac0df06b64480e:e739xxx9f-ebfa-45xx-b038-740xx6519::"
  cos_kms_key_crn               = "crn:v1:bluemix:public:kms:eu-de:a/abac0df06b644ae:9171b85b-cexx-4cxx-80be-f5648428:key:c60f124a-8sfsf-fdjg"
}

```

### Required access policies

You need the following permissions to run this module:

- Account Management
    - **Resource group**
        - `Viewer` access on the specific resource group
- IAM services
    - **Watson Machine Learning** service
        - `Editor` platform access
    - **Watson Studio** service
        - `Editor` platform access
    - **Cloud Object Storage** service
        - `Editor` platform access
        - `Manager` service access



<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->


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
| <a name="module_cos_crn_parser"></a> [cos\_crn\_parser](#module\_cos\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
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
| <a name="input_cos_instance_crn"></a> [cos\_instance\_crn](#input\_cos\_instance\_crn) | The CRN of the Cloud Object Storage instance. | `string` | n/a | yes |
| <a name="input_cos_kms_key_crn"></a> [cos\_kms\_key\_crn](#input\_cos\_kms\_key\_crn) | The CRN of a KMS key. It is used to encrypt the COS buckets used by the watsonx projects. | `string` | `null` | no |
| <a name="input_create_watsonx_ai_project"></a> [create\_watsonx\_ai\_project](#input\_create\_watsonx\_ai\_project) | Whether to create and configure a starter watsonx.ai project. | `bool` | `true` | no |
| <a name="input_enable_cos_kms_encryption"></a> [enable\_cos\_kms\_encryption](#input\_enable\_cos\_kms\_encryption) | Flag to enable COS KMS encryption. If set to true, a value must be passed for `existing_cos_kms_key_crn`. | `bool` | `false` | no |
| <a name="input_existing_machine_learning_instance_crn"></a> [existing\_machine\_learning\_instance\_crn](#input\_existing\_machine\_learning\_instance\_crn) | The CRN of an existing Watson Machine Learning instance. If not provided, a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_existing_watsonx_ai_studio_instance_crn"></a> [existing\_watsonx\_ai\_studio\_instance\_crn](#input\_existing\_watsonx\_ai\_studio\_instance\_crn) | The CRN of an existing Watson Studio instance. If not provided, a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to add to all watsonx.ai resources created by this module. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region where the watsonx resources will be provisioned. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where the watsonx services will be provisioned. Required when creating a new instance. | `string` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to describe the service instances created by the module. | `list(string)` | `[]` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the KMS instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to avoid creating the policy. | `bool` | `false` | no |
| <a name="input_watsonx_ai_runtime_instance_name"></a> [watsonx\_ai\_runtime\_instance\_name](#input\_watsonx\_ai\_runtime\_instance\_name) | The name of the Watson Machine Learning instance to create. If a prefix input variable is passed, it is prefixed to the value in the `<prefix>-value` format. | `string` | `"watsonx-ml"` | no |
| <a name="input_watsonx_ai_runtime_plan"></a> [watsonx\_ai\_runtime\_plan](#input\_watsonx\_ai\_runtime\_plan) | The plan that is used to provision the Watson Machine Learning instance. Allowed values are 'lite', 'v2-professional' and 'v2-standard'. | `string` | `"lite"` | no |
| <a name="input_watsonx_ai_runtime_service_endpoints"></a> [watsonx\_ai\_runtime\_service\_endpoints](#input\_watsonx\_ai\_runtime\_service\_endpoints) | The type of service endpoints. Possible values: 'public', 'private', 'public-and-private'. | `string` | `"public"` | no |
| <a name="input_watsonx_ai_studio_instance_name"></a> [watsonx\_ai\_studio\_instance\_name](#input\_watsonx\_ai\_studio\_instance\_name) | The name of the Watson Studio instance to create. If a prefix input variable is passed, it is prefixed to the value in the `<prefix>-value` format. | `string` | `"watsonx-studio"` | no |
| <a name="input_watsonx_ai_studio_plan"></a> [watsonx\_ai\_studio\_plan](#input\_watsonx\_ai\_studio\_plan) | The plan that is used to provision the Watson Studio instance. Allowed values are 'free-v1' and 'professional-v1'. | `string` | `"free-v1"` | no |
| <a name="input_watsonx_mark_as_sensitive"></a> [watsonx\_mark\_as\_sensitive](#input\_watsonx\_mark\_as\_sensitive) | Set to true to allow the watsonx.ai project to be created with 'Mark as sensitive' flag. It enforces access restriction and prevents data from being moved out of the project. | `bool` | `false` | no |
| <a name="input_watsonx_project_description"></a> [watsonx\_project\_description](#input\_watsonx\_project\_description) | A description of the watsonx.ai project that is created. | `string` | `"Watsonx project created by the watsonx.ai module."` | no |
| <a name="input_watsonx_project_name"></a> [watsonx\_project\_name](#input\_watsonx\_project\_name) | The name of the watsonx.ai project. | `string` | `"demo"` | no |
| <a name="input_watsonx_project_tags"></a> [watsonx\_project\_tags](#input\_watsonx\_project\_tags) | A list of tags associated with the watsonx.ai project. Each tag consists of a string containing up to 255 characters. These tags can include spaces, letters, numbers, underscores, dashes, as well as the symbols # and @. | `list(string)` | <pre>[<br/>  "watsonx-ai"<br/>]</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_watsonx_ai_runtime_account_id"></a> [watsonx\_ai\_runtime\_account\_id](#output\_watsonx\_ai\_runtime\_account\_id) | The account id of the Watson Machine Learning instance. |
| <a name="output_watsonx_ai_runtime_crn"></a> [watsonx\_ai\_runtime\_crn](#output\_watsonx\_ai\_runtime\_crn) | The CRN of the Watson Machine Learning instance. |
| <a name="output_watsonx_ai_runtime_dashboard_url"></a> [watsonx\_ai\_runtime\_dashboard\_url](#output\_watsonx\_ai\_runtime\_dashboard\_url) | The dashboard URL of the Watson Machine Learning instance. |
| <a name="output_watsonx_ai_runtime_guid"></a> [watsonx\_ai\_runtime\_guid](#output\_watsonx\_ai\_runtime\_guid) | The GUID of the Watson Machine Learning instance. |
| <a name="output_watsonx_ai_runtime_name"></a> [watsonx\_ai\_runtime\_name](#output\_watsonx\_ai\_runtime\_name) | The name of the Watson Machine Learning instance. |
| <a name="output_watsonx_ai_runtime_plan_id"></a> [watsonx\_ai\_runtime\_plan\_id](#output\_watsonx\_ai\_runtime\_plan\_id) | The plan ID of the Watson Machine Learning instance. |
| <a name="output_watsonx_ai_studio_crn"></a> [watsonx\_ai\_studio\_crn](#output\_watsonx\_ai\_studio\_crn) | The CRN of the Watson Studio instance. |
| <a name="output_watsonx_ai_studio_dashboard_url"></a> [watsonx\_ai\_studio\_dashboard\_url](#output\_watsonx\_ai\_studio\_dashboard\_url) | The dashboard URL of the Watson Studio instance. |
| <a name="output_watsonx_ai_studio_guid"></a> [watsonx\_ai\_studio\_guid](#output\_watsonx\_ai\_studio\_guid) | The GUID of the Watson Studio instance. |
| <a name="output_watsonx_ai_studio_name"></a> [watsonx\_ai\_studio\_name](#output\_watsonx\_ai\_studio\_name) | The name of the Watson Studio instance. |
| <a name="output_watsonx_ai_studio_plan_id"></a> [watsonx\_ai\_studio\_plan\_id](#output\_watsonx\_ai\_studio\_plan\_id) | The plan ID of the Watson Studio instance. |
| <a name="output_watsonx_project_bucket_name"></a> [watsonx\_project\_bucket\_name](#output\_watsonx\_project\_bucket\_name) | The name of the COS bucket created for the watsonx project. |
| <a name="output_watsonx_project_id"></a> [watsonx\_project\_id](#output\_watsonx\_project\_id) | The ID of the watsonx project that's created. |
| <a name="output_watsonx_project_region"></a> [watsonx\_project\_region](#output\_watsonx\_project\_region) | The region of the watsonx project that's created. |
| <a name="output_watsonx_project_url"></a> [watsonx\_project\_url](#output\_watsonx\_project\_url) | The URL of the watsonx project that's created. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
