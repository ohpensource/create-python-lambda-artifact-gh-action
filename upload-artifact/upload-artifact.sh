#!/bin/bash
set -e
wrk_dir=$(pwd)

log_action() {
    echo "${1^^} ..."
}

log_error() {
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color
    echo -e "\n${RED}${1^^} ${NC}..."
}

log_key_value_pair() {
    echo "    $1: $2"
}

set_up_aws_user_credentials() {
    unset AWS_SESSION_TOKEN
    export AWS_DEFAULT_REGION=$1
    export AWS_ACCESS_KEY_ID=$2
    export AWS_SECRET_ACCESS_KEY=$3
}

assume_role() {
    local CREDENTIALS_FILE_NAME="aws-credentials-$(basename "$0").json"
    if [[ ! -f "$CREDENTIALS_FILE_NAME" ]]; then
        local AWS_ACCOUNT_ID=$1
        local ROLE_NAME=$2
        local ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/$ROLE_NAME"
        aws sts assume-role --role-arn $ROLE_ARN --role-session-name github-session > $CREDENTIALS_FILE_NAME
    fi

    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' $CREDENTIALS_FILE_NAME)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' $CREDENTIALS_FILE_NAME)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' $CREDENTIALS_FILE_NAME)
}

function zip_folder() {
    folder=$1
    zip_file=$2
    rm -f $zip_file
    zip -r $zip_file $folder
}

log_action "Creating python lambda artifact"
while getopts r:a:s:c:o:b:n:v:m: flag
do
    case "${flag}" in
       r) aws_region=${OPTARG};;
       a) access_key=${OPTARG};;
       s) secret_key=${OPTARG};;
       c) account_id=${OPTARG};;
       o) role_name=${OPTARG};;
       b) bucket_name=${OPTARG};;
       n) service_name=${OPTARG};;
       v) version=${OPTARG};;
       m) module_path="${OPTARG}";;
    esac
done
log_key_value_pair "aws_region" $aws_region
log_key_value_pair "access_key" $access_key
# log_key_value_pair "secret_key" $secret_key
log_key_value_pair "account_id" $account_id
log_key_value_pair "role_name" $role_name
log_key_value_pair "bucket_name" $bucket_name
log_key_value_pair "service_name" $service_name
log_key_value_pair "version" $version
log_key_value_pair "module_path" $module_path

set_up_aws_user_credentials $aws_region $access_key $secret_key
assume_role $account_id $role_name

module_path="$wrk_dir/$module_path"
version=$(echo "$version"|tr '/' '-')
parent_dir="$(dirname "$module_path")"
cd $parent_dir
    module_folder="$(basename "$module_path")"
    zip_file="$module_folder.zip"
    zip_folder $module_folder $zip_file
    s3_destination="s3://$bucket_name/artifacts/$service_name/$version/$service_name-$version.zip"
    log_key_value_pair "s3-destination" $s3_destination
    aws s3 cp $zip_file $s3_destination
cd $wrk_dir