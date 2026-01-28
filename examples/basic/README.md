# Basic example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=watsonx-ai-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-watsonx-ai/tree/main/examples/basic"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An example that will provision the following:
- A new resource group if one is not passed in.
- A Cloud Object Storage instance.
- A `watsonx.ai Studio` instance.
- A `watsonx.ai Runtime` instance.
- Configure the `watsonx.ai` profile for IBM Cloud user.
- Create a IBM `watsonx.ai` project without KMS encryption.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
