# IBM watsonx.ai deployable architecture

This deployable architecture supports provisioning the following resources:

- A new resource group if one is not passed in.
- A watsonx.ai Studio instance.
- A watsonx.ai Runtime instance.
- A Cloud Object Storage instance.
- A new key-ring and key in the KMS(Key Protect) instance, if an existing key is not provided.
- Configure the watsonx profile for IBM Cloud user.
- Create a KMS encryption enabled IBM watsonx.ai project.

![watsonx-ai-deployable-architecture](../../reference-architecture/watsonx-ai-da.svg)

:exclamation: **Important:** This solution is not intended to be called by other modules because it contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).
