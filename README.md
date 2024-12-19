<!-- Update this title with a descriptive name. Use sentence case. -->
# Watsonx.ai module

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
* [Examples](./examples)
    * [Advanced example](./examples/complete)
    * [Basic example](./examples/basic)
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

* Provision the following services:
    * Watson Studio
    * Watson Machine Learning
    * Cloud Object Storage
* Configuring the IBM watsonx profile and creating a starter IBM watsonx project. for an IBM Cloud user, who becomes the admin of the IBM watsonx project.

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl

```

### Required access policies

You need the following permissions to run this module:

- Service
    <!-- - **Resource group only**
        - `Viewer` access on the specific resource group -->
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
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.70.1 |

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
| [ibm_resource_instance.watson_machine_learning_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.watson_studio_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.existing_watson_machine_learning_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |
| [ibm_resource_instance.existing_watson_studio_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cos_instance_crn"></a> [cos\_instance\_crn](#input\_cos\_instance\_crn) | The CRN of the Cloud Object Storage instance. | `string` | n/a | yes |
| <a name="input_cos_kms_key_crn"></a> [cos\_kms\_key\_crn](#input\_cos\_kms\_key\_crn) | The CRN of a KMS key. It is used to encrypt the COS buckets used by the watsonx projects. | `string` | `null` | no |
| <a name="input_enable_configure_project"></a> [enable\_configure\_project](#input\_enable\_configure\_project) | Whether to configure project. | `bool` | `true` | no |
| <a name="input_enable_cos_kms_encryption"></a> [enable\_cos\_kms\_encryption](#input\_enable\_cos\_kms\_encryption) | Flag to enable COS KMS encryption. If set to true, a value must be passed for `existing_cos_kms_key_crn`. | `bool` | `false` | no |
| <a name="input_existing_machine_learning_instance_crn"></a> [existing\_machine\_learning\_instance\_crn](#input\_existing\_machine\_learning\_instance\_crn) | The CRN of an existing Watson Machine Learning instance. If not provided, a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_existing_watson_studio_instance_crn"></a> [existing\_watson\_studio\_instance\_crn](#input\_existing\_watson\_studio\_instance\_crn) | The CRN of an existing Watson Studio instance. If not provided, a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The API key that's used with the IBM Cloud Terraform IBM provider. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The name to be used on all Watson resources as a prefix. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region where the watsonx resources will be provisioned. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where the watsonx services will be provisioned. Required when creating a new instance. | `string` | `null` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the KMS instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to avoid creating the policy. | `bool` | `false` | no |
| <a name="input_watson_machine_learning_plan"></a> [watson\_machine\_learning\_plan](#input\_watson\_machine\_learning\_plan) | The plan that is used to provision the Watson Machine Learning instance. | `string` | `"lite"` | no |
| <a name="input_watson_machine_learning_service_endpoints"></a> [watson\_machine\_learning\_service\_endpoints](#input\_watson\_machine\_learning\_service\_endpoints) | The type of service endpoints. Possible values: 'public', 'private', 'public-and-private'. | `string` | `"public"` | no |
| <a name="input_watson_studio_plan"></a> [watson\_studio\_plan](#input\_watson\_studio\_plan) | The plan that is used to provision the Watson Studio instance. The plan you choose for Watson Studio affects the features and capabilities that you can use. | `string` | `"free-v1"` | no |
| <a name="input_watsonx_admin_api_key"></a> [watsonx\_admin\_api\_key](#input\_watsonx\_admin\_api\_key) | The API key of the IBM watsonx administrator in the target account. The API key is used to configure the user and the project. | `string` | `null` | no |
| <a name="input_watsonx_mark_as_sensitive"></a> [watsonx\_mark\_as\_sensitive](#input\_watsonx\_mark\_as\_sensitive) | Set to true to allow the Watsonx.ai project to be created with 'Mark as sensitive' flag. | `bool` | `false` | no |
| <a name="input_watsonx_project_description"></a> [watsonx\_project\_description](#input\_watsonx\_project\_description) | A description of the Watsonx.ai project that is created. | `string` | `"Watsonx project created by the watsonx.ai module."` | no |
| <a name="input_watsonx_project_name"></a> [watsonx\_project\_name](#input\_watsonx\_project\_name) | The name of the Watsonx.ai project. | `string` | `"demo"` | no |
| <a name="input_watsonx_project_tags"></a> [watsonx\_project\_tags](#input\_watsonx\_project\_tags) | A list of tags associated with the watsonx.ai project. Each tag consists of a single string containing up to 255 characters. These tags can include spaces, letters, numbers, underscores, dashes, as well as the symbols # and @. | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_watson_machine_learning_crn"></a> [watson\_machine\_learning\_crn](#output\_watson\_machine\_learning\_crn) | The CRN of the Watson Machine Learning instance. |
| <a name="output_watson_machine_learning_dashboard_url"></a> [watson\_machine\_learning\_dashboard\_url](#output\_watson\_machine\_learning\_dashboard\_url) | The dashboard URL of the Watson Machine Learning instance. |
| <a name="output_watson_machine_learning_guid"></a> [watson\_machine\_learning\_guid](#output\_watson\_machine\_learning\_guid) | The GUID of the Watson Machine Learning instance. |
| <a name="output_watson_machine_learning_name"></a> [watson\_machine\_learning\_name](#output\_watson\_machine\_learning\_name) | The name of the Watson Machine Learning instance. |
| <a name="output_watson_machine_learning_plan_id"></a> [watson\_machine\_learning\_plan\_id](#output\_watson\_machine\_learning\_plan\_id) | The plan ID of the Watson Machine Learning instance. |
| <a name="output_watson_studio_crn"></a> [watson\_studio\_crn](#output\_watson\_studio\_crn) | The CRN of the Watson Studio instance. |
| <a name="output_watson_studio_dashboard_url"></a> [watson\_studio\_dashboard\_url](#output\_watson\_studio\_dashboard\_url) | The dashboard URL of the Watson Studio instance. |
| <a name="output_watson_studio_guid"></a> [watson\_studio\_guid](#output\_watson\_studio\_guid) | The GUID of the Watson Studio instance. |
| <a name="output_watson_studio_name"></a> [watson\_studio\_name](#output\_watson\_studio\_name) | The name of the Watson Studio instance. |
| <a name="output_watson_studio_plan_id"></a> [watson\_studio\_plan\_id](#output\_watson\_studio\_plan\_id) | The plan ID of the Watson Studio instance. |
| <a name="output_watsonx_project_bucket_name"></a> [watsonx\_project\_bucket\_name](#output\_watsonx\_project\_bucket\_name) | The name of the COS bucket created by the watsonx project. |
| <a name="output_watsonx_project_id"></a> [watsonx\_project\_id](#output\_watsonx\_project\_id) | The ID watsonx project that's created. |
| <a name="output_watsonx_project_location"></a> [watsonx\_project\_location](#output\_watsonx\_project\_location) | The location watsonx project that's created. |
| <a name="output_watsonx_project_url"></a> [watsonx\_project\_url](#output\_watsonx\_project\_url) | The URL of the watsonx project that's created. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
