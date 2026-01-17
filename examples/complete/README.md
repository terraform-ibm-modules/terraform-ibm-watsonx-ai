# Complete example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=watsonx-ai-complete-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-watsonx-ai/tree/main/examples/complete"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An end-to-end complete example that will provision the following:
- A new resource group if one is not passed in.
- A Cloud Object Storage instance.
- A KMS (Key Protect) instance.
- A new key-ring and key in the KMS instance.
- A watsonx Studio instance.
- A watsonx Runtime instance.
- Configure the watsonx profile for IBM Cloud user.
- Create a COS-KMS encryption enabled IBM watsonx project.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
