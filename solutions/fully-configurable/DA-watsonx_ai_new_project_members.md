# Adding Additional Members to a Watsonx.ai Project

The `watsonx_ai_new_project_members` input variable allows you to specify additional members that you would like to add to your Watsonx.ai project.
- Variable name: `watsonx_ai_new_project_members`
- Type: a list of objects
- Default value: an empty list ( [] )

### Member Object
- `email` (required): The username of the new member, typically an email.
- `iam_id` (required): The IBM Cloud IAM ID of the new member. It can be found in the IBM Cloud UI under `Manage>Access (IAM)>Manage identities>Users`. Then search for the desired member.
- `role` (required): The desired role for the new member in the account. The valid options are admin, editor, or viewer.
- `state` (optional): The state of the new member. Valid options are ACTIVE or PENDING, with a default of ACTIVE.
- `type` (optional): The type or new member. Valid options are user, group, service, profile, with a default of user.

### Example New Project Members Variable
This is an example of adding two new members, one as an admin and one as a viewer to the project:
```json
"members": [
    {
        "email": "example@ibm.com",
        "iam_id": "IBMid-1111111111",
        "role": "admin"
    },
    {
        "email": "example1@ibm.com",
        "iam_id": "IBMid-1111111110",
        "role": "viewer",
        "state": "ACTIVE",
        "type": "service"
    }
]
```
