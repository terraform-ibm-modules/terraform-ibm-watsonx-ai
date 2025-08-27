#! /bin/bash

############################################################################################################
## This script is used by the catalog pipeline to provision a new resource group and cos instance
## (required as temporary workaround for issue https://github.ibm.com/GoldenEye/issues/issues/15533)
############################################################################################################

set -e

DA_DIR="${1}"
TERRAFORM_SOURCE_DIR="tests/new_cos_instance"
JSON_FILE="${DA_DIR}/catalogValidationValues.json.template"
TF_VARS_FILE="terraform.tfvars"

(
  cwd=$(pwd)
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Provisioning new resource group and cos instance .."
  terraform init || exit 1
  # $VALIDATION_APIKEY is available in the catalog runtime
  {
    echo "ibmcloud_api_key=\"${VALIDATION_APIKEY}\""
    echo "prefix=\"wxai-$(openssl rand -hex 2)\""
  } >> ${TF_VARS_FILE}
  terraform apply -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  cos_var_name="existing_cos_instance_crn"
  cos_value=$(terraform output -state=terraform.tfstate -raw cos_crn)

  echo "Appending '${cos_var_name}', input variable value to ${JSON_FILE}.."

  cd "${cwd}"
  jq -r --arg cos_var_name "${cos_var_name}" \
        --arg cos_value "${cos_value}" \
        '. + {($cos_var_name): $cos_value}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
