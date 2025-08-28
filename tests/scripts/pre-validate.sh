#! /bin/bash

############################################################################################################
## This script is used by the catalog pipeline to provision a new resource group and cos instance
## (required as temporary workaround for issue https://github.ibm.com/GoldenEye/issues/issues/15533)
############################################################################################################

set -e

DA_DIR="${1}"
TERRAFORM_SOURCE_DIR="tests/resources/kp-cos-instance"
JSON_FILE="${DA_DIR}/catalogValidationValues.json"
TF_VARS_FILE="terraform.tfvars"

(
  cwd=$(pwd)
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Provisioning new resource group, kms instance and cos instance .."
  terraform init || exit 1
  # $VALIDATION_APIKEY is available in the catalog runtime
  {
    echo "ibmcloud_api_key=\"${VALIDATION_APIKEY}\""
    echo "prefix=\"wxai-$(openssl rand -hex 2)\""
    echo "region=\"us-south\""
  } >> ${TF_VARS_FILE}
  terraform apply -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  cos_var_name="existing_cos_instance_crn"
  cos_value=$(terraform output -state=terraform.tfstate -raw cos_crn)
  kms_var_name="existing_kms_instance_crn"
  kms_value=$(terraform output -state=terraform.tfstate -raw key_protect_crn)
  rg_var_name="existing_resource_group_name"
  rg_value=$(terraform output -state=terraform.tfstate -raw resource_group_name)

  echo "Appending '${cos_var_name}' and '${kms_var_name}', input variables to ${JSON_FILE}.."

  cd "${cwd}"
  jq -r --arg cos_var_name "${cos_var_name}" \
        --arg cos_value "${cos_value}" \
        '. + {($cos_var_name): $cos_value}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}" || exit 1
  jq -r --arg kms_var_name "${kms_var_name}" \
        --arg kms_value "${kms_value}" \
        '. + {($kms_var_name): $kms_value}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}" || exit 1
  jq -r --arg rg_var_name "${rg_var_name}" \
        --arg rg_value "${rg_value}" \
        '. + {($rg_var_name): $rg_value}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
