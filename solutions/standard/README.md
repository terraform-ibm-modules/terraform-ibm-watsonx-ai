# IBM watsonx.ai deployable architecture

This deployable architecture supports provisioning the following resources:

- A new resource group if one is not passed in.
- A watsonx.ai Studio instance.
- A watsonx.ai Runtime instance.
- A Cloud Object Storage instance.
- A new key-ring and key in the KMS(Key Protect) instance, if an existing key is not provided.
- Configure the watsonx profile for IBM Cloud user.
- Create a KMS encryption enabled IBM watsonx.ai project.
