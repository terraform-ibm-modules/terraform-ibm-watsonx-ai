# Configure watsonx.ai project submodule

This submodule is used to create and configure the IBM watsonx.ai Project. For more information, read [here](https://dataplatform.cloud.ibm.com/docs/content/wsj/getting-started/projects.html?context=wx&audience=wdp).

## Resources updated on every apply

If you set `watsonx_ai_new_project_members`, Terraform shows one `null_resource.add_collaborators_to_project` entry per collaborator as "must be replaced" (`-/+`) on every `terraform plan` and `terraform apply`, even when you haven't changed any input. For example:

```text
# module.watsonx_ai.module.configure_project[0].null_resource.add_collaborators_to_project["user@example.com"] must be replaced
-/+ resource "null_resource" "add_collaborators_to_project" {
      ~ id       = "6290518102018860361" -> (known after apply)
      ~ triggers = { # forces replacement
          ~ "always_run" = "2025-01-01T00:00:00Z" -> (known after apply)
        }
    }
```

### Why this happens

Collaborators are added to the project through a script that calls the watsonx.ai API. Terraform has no native resource for this, so it can't check whether a collaborator is still in the project. To keep the project in sync with your configuration, the module uses a `null_resource` with a `timestamp()` trigger. The trigger value changes on every run, so Terraform replaces the resource and runs the script again each time.

### What it means for you

* **Your infrastructure is not affected.** A `null_resource` doesn't represent anything in IBM Cloud, so replacing it only updates the Terraform state. No IBM Cloud resource is created, changed, or deleted.
* **Collaborators are re-added on every apply.** The script re-submits every entry in `watsonx_ai_new_project_members` to the project. If a user, service ID, access group, or trusted profile was removed from the project's **Access control** > **Collaborators** list in the watsonx.ai UI, the next apply attempts to add it again.
* **You can safely ignore these entries in the plan.** They don't indicate drift or an error.
