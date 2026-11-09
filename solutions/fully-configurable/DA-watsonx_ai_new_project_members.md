# Adding Additional Members to a Watsonx.ai Project

The `watsonx_ai_new_project_members` input variable allows you to specify additional members that you would like to add to your Watsonx.ai project.
- Variable name: `watsonx_ai_new_project_members`
- Type: a list of objects
- Default value: an empty list ( [] )

### Member Object
- `email` (required): The username of the new member, typically an email. If member type is not user, email and iam_id must match.
- `iam_id` (required): The IBM Cloud IAM ID of the new member. It can be found in the IBM Cloud UI under `Manage>Access (IAM)>Manage identities>Users`. Then search for the desired member.
- `role` (required): The desired role for the new member in the account. The valid options are admin, editor, or viewer.
- `state` (optional): The state of the new member. Valid options are ACTIVE or PENDING, with a default of ACTIVE.
- `type` (optional): The type or new member. Valid options are user, group, service, profile, with a default of user.

### Example New Project Members Variable
This is an example of adding two new members, one as an admin and one as a viewer to the project:

```json
[
  {
    "email": "example@ibm.com",
    "iam_id": "IBMid-1111111111",
    "role": "admin"
  },
  {
    "email": "IBMid-1111111110",
    "iam_id": "IBMid-1111111110",
    "role": "viewer",
    "state": "ACTIVE",
    "type": "service"
  }
]
```

**Note:** The `null_resource.add_collaborators_to_project` resource in the `configure_project` submodule is replaced (`-/+`) on every `terraform plan` and `terraform apply` when `watsonx_ai_new_project_members` is set. This is expected behavior. The `null_resource` doesn't represent an IBM Cloud resource, but each replacement runs a script that calls the watsonx.ai API to add the collaborators.

A `timestamp()` trigger forces the script to run on every apply, so any collaborator (user, service ID, access group, or trusted profile) removed directly from the watsonx.ai project outside of Terraform is added again on the next apply. For details, see [Resources updated on every apply](../../modules/configure_project/README.md#resources-updated-on-every-apply).
