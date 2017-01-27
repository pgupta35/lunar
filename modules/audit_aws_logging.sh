# audit_aws_logging
#
# AWS CloudTrail is a web service that records AWS API calls for your account
# and delivers log files to you. The recorded information includes the identity
# of the API caller, the time of the API call, the source IP address of the API
# caller, the request parameters, and the response elements returned by the AWS
# service. CloudTrail provides a history of AWS API calls for an account,
# including API calls made via the Management Console, SDKs, command line tools,
# and higher-level AWS services (such as CloudFormation).
#
# The AWS API call history produced by CloudTrail enables security analysis,
# resource change tracking, and compliance auditing. Additionally, ensuring that
# a multi-regions trail exists will ensure that unexpected activity occurring in
# otherwise unused regions is detected.
#
# CloudTrail logs a record of every API call made in your AWS account.
# These logs file are stored in an S3 bucket. It is recommended that the bucket
# policy or access control list (ACL) applied to the S3 bucket that CloudTrail
# logs to prevents public access to the CloudTrail logs.
#
# Allowing public access to CloudTrail log content may aid an adversary in
# identifying weaknesses in the affected account's use or configuration.
#
# AWS CloudTrail is a web service that records AWS API calls made in a given AWS
# account. The recorded information includes the identity of the API caller,
# the time of the API call, the source IP address of the API caller, the request
# parameters, and the response elements returned by the AWS service. CloudTrail
# uses Amazon S3 for log file storage and delivery, so log files are stored
# durably. In addition to capturing CloudTrail logs within a specified S3 bucket
# for long term analysis, realtime analysis can be performed by configuring
# CloudTrail to send logs to CloudWatch Logs. For a trail that is enabled in all
# regions in an account, CloudTrail sends log files from all those regions to a
# CloudWatch Logs log group. It is recommended that CloudTrail logs be sent to
# CloudWatch Logs.
#
# Note: The intent of this recommendation is to ensure AWS account activity is
# being captured, monitored, and appropriately alarmed on. CloudWatch Logs is a
# native way to accomplish this using AWS services but does not preclude the use
# of an alternate solution.
#
# Sending CloudTrail logs to CloudWatch Logs will facilitate real-time and
# historic activity logging based on user, API, resource, and IP address, and
# provides opportunity to establish alarms and notifications for anomalous or
# sensitivity account activity.
#
# S3 Bucket Access Logging generates a log that contains access records for each
# request made to your S3 bucket. An access log record contains details about
# the request, such as the request type, the resources specified in the request
# worked, and the time and date the request was processed. It is recommended
#that bucket access logging be enabled on the CloudTrail S3 bucket.
#
# By enabling S3 bucket logging on target S3 buckets, it is possible to capture
# all events which may affect objects within an target buckets. Configuring logs
# to be placed in a separate bucket allows access to log information which can
# be useful in security and incident response workflows.
#
# AWS CloudTrail is a web service that records AWS API calls for an account and
# makes those logs available to users and resources in accordance with IAM
# policies. AWS Key Management Service (KMS) is a managed service that helps
# create and control the encryption keys used to encrypt account data, and uses
# Hardware Security Modules (HSMs) to protect the security of encryption keys.
# CloudTrail logs can be configured to leverage server side encryption (SSE) and
# KMS customer created master keys (CMK) to further protect CloudTrail logs.
# It is recommended that CloudTrail be configured to use SSE-KMS.
#
# Configuring CloudTrail to use SSE-KMS provides additional confidentiality
# controls on log data as a given user must have S3 read permission on the
# corresponding log bucket and must be granted decrypt permission by the CMK
# policy.
#
# Refer to Section(s) 2.1 Page(s) 70-1 CIS AWS Foundations Benchmark v1.1.0
# Refer to Section(s) 2.2 Page(s) 72-3 CIS AWS Foundations Benchmark v1.1.0
# Refer to Section(s) 2.3 Page(s) 74-5 CIS AWS Foundations Benchmark v1.1.0
# Refer to Section(s) 2.4 Page(s) 76-7 CIS AWS Foundations Benchmark v1.1.0
# Refer to Section(s) 2.6 Page(s) 81-2 CIS AWS Foundations Benchmark v1.1.0
# Refer to Section(s) 2.7 Page(s) 83-4 CIS AWS Foundations Benchmark v1.1.0
#
# Ensure that your AWS CloudTrail logging bucket use Multi-Factor Authentication
# (MFA) Delete feature in order to prevent the deletion of any versioned log
# files.
#
# Using an MFA-protected bucket for AWS CloudTrail will enable the ultimate
# layer of protection to ensure that your versioned log files cannot be
# accidentally deleted or intentionally deleted in case your access
# credentials are compromised.
#
# Refer to https://www.cloudconformity.com/conformity-rules/CloudTrail/cloudtrail-bucket-mfa-delete-enabled.html
#
# Ensure that CloudTrail is enabled for all AWS regions in order to increase
# the visibility of the API activity in your AWS account for security and
# management purposes.
#
# Enabling global monitoring for your existing trails will help you to better
# manage your AWS account and maintain the security of you infrastructure.
#
# Applying your trail to all AWS regions has multiple advantages, such as
# receiving storing log files from all regions in a single S3 bucket and a
# single CloudWatch Logs group. It also enables managing trail configuration
# for all regions from one location and recording of API calls in regions that
# are not used to detect any unusual activity.
#
# Refer to https://www.cloudconformity.com/conformity-rules/CloudTrail/cloudtrail-enabled.html
#
# Check for any AWS CloudTrail logging buckets that are publicly accessible,
# in order to determine if your AWS account could be at risk.
#
# Using an overly permissive or insecure set of permissions for your CloudTrail
# logging S3 buckets could provide malicious users access to your AWS account
# log data which can increase exponentially the risk of unauthorized access.
#
# Refer to https://www.cloudconformity.com/conformity-rules/CloudTrail/cloudtrail-bucket-publicly-accessible.html
#
# Ensure that any S3 buckets used by AWS CloudTrail have Server Access Logging
# feature enabled in order to track requests for accessing the buckets and
# necessary for security audits.
#
# Since CloudTrail buckets contain sensitive information, these should be
# protected from unauthorized viewing. With S3 Server Access Logging enabled
# for your CloudTrail buckets you can track any requests made to access the
# buckets or even limit who can alter or delete the access logs to prevent a
# user from covering their tracks.
#
# Refer to https://www.cloudconformity.com/conformity-rules/CloudTrail/cloudtrail-s3-bucket-logging-enabled.html
#.

audit_aws_logging () {
	check=`aws cloudtrail describe-trails --region $aws_region |grep IsMultiRegionTrail |grep true`
	if [ "$check" ]; then
    # Check CloudTrail has MultiRegion enabled
    trails=`aws cloudtrail describe-trails --region $aws_region --query "trailList[].Name" --output text`
    for trail in $trails; do
      total=`expr $total + 1`
      check=`aws cloudtrail describe-trails --region $aws_region --trail-name-list $trail --query "trailList[].IsMultiRegionTrail" |grep true`
      if [ "$check" ]; then
        secure=`expr $secure + 1`
        echo "Secure:    CloudTrail $trail is enabled in all regions [$secure Passes]"
    	else
        insecure=`expr $insecure + 1`
        echo "Warning:   CloudTrail $trail is not enabled in all regions [$insecure Warnings]"
        funct_verbose_message "" fix
        funct_verbose_message "aws cloudtrail update-trail --name $trail --is-multi-region-trail" fix
        funct_verbose_message "" fix

      fi
      # Check log file validation is enabled
      total=`expr $total + 1`
      check=`aws cloudtrail describe-trails --region $aws_region --trail-name-list $trail --query "trailList[].LogFileValidationEnabled" |grep true`
      if [ "$check" ]; then
        secure=`expr $secure + 1`
        echo "Secure:    CloudTrail $trail log file validation is enabled [$secure Passes]"
      else
        insecure=`expr $insecure + 1`
        echo "Warning:   CloudTrail $trail log file validation is not enabled [$insecure Warnings]"
        funct_verbose_message "" fix
        funct_verbose_message "aws cloudtrail update-trail --region $aws_region --name $trail --enable-log-file-validation" fix
        funct_verbose_message "" fix
      fi
    done
    buckets=`aws cloudtrail describe-trails --region $aws_region --query 'trailList[*].S3BucketName' --output text`
    # Check that CloudTrail buckets don't grant access to users it shouldn't
    # Check that CloudTrail bucket versioning is enable
    for bucket in $buckets; do
      total=`expr $total + 1`
      grants=`aws s3api get-bucket-acl --region $aws_region --bucket $bucket |grep URI |grep AllUsers`
      if [ "$grants" ]; then
        insecure=`expr $insecure + 1`
        echo "Warning:   CloudTrail log file bucket $bucket grants access to Principal AllUsers [$insecure Warnings]"
      else
        secure=`expr $secure + 1`
        echo "Secure:    CloudTrail log file bucket $bucket does not grant access to Principal AllUsers [$secure Passes]"
      fi
      total=`expr $total + 1`
      grants=`aws s3api get-bucket-acl --region $aws_region --bucket $bucket |grep URI |grep AuthenticatedUsers`
      if [ "$grants" ]; then
        insecure=`expr $insecure + 1`
        echo "Warning:   CloudTrail log file bucket $bucket grants access to Principal AuthenticatedUsers [$insecure Warnings]"
        funct_verbose_message "" fix
        funct_verbose_message "aws s3api put-bucket-acl --region $aws_region --region $aws_region--bucket $bucket --acl private" fix
        funct_verbose_message "" fix
      else
        secure=`expr $secure + 1`
        echo "Secure:    CloudTrail log file bucket $bucket does not grant access to Principal AuthenticatedUsers [$secure Passes]"
      fi
      total=`expr $total + 1`
      grants=`aws s3api get-bucket-policy --region $aws_region --bucket $bucket --query Policy |tr "}" "\n" |grep Allow |grep "*"`
      if [ "$grants" ]; then
        insecure=`expr $insecure + 1`
        echo "Warning:   CloudTrail log file bucket $bucket grants access to Principal * [$insecure Warnings]"
      else
        secure=`expr $secure + 1`
        echo "Secure:    CloudTrail log file bucket $bucket does not grant access to Principal * [$secure Passes]"
      fi
      logging=`aws s3api get-bucket-logging --region $aws_region --bucket $bucket`
      if [ ! "$logging" ]; then
        insecure=`expr $insecure + 1`
        echo "Warning:   CloudTrail log file bucket $bucket does not have access logging enabled [$insecure Warnings]"
        funct_verbose_message "" fix
        funct_verbose_message "aws s3api put-bucket-acl --region $aws_region --bucket $bucket --grant-write URI=http://acs.amazonaws.com/groups/s3/LogDelivery --grant-read-acp URI=http://acs.amazonaws.com/groups/s3/LogDelivery" fix
        funct_verbose_message "cd aws ; aws s3api put-bucket-logging --region $aws_region --bucket $bucket --bucket-logging-status file://server-access-logging.json"
        funct_verbose_message "" fix
      else
        secure=`expr $secure + 1`
        echo "Secure:    CloudTrail log file bucket $bucket has access logging enabled [$secure Passes]"
      fi
      total=`expr $total + 1`
      check=`aws s3api get-bucket-versioning --bucket $bucket |grep Enabled`
      if [ "$check" ]; then
        secure=`expr $secure + 1`
        echo "Secure:    CloudTrail log bucket $bucket has versioning enabled [$secure Passes]"
      else
        insecure=`expr $insecure + 1`
        echo "Warning:   CloudTrail bucket $bucket does not have versioning enabled [$insecure Warnings]"
      fi
    done
    trails=`aws cloudtrail describe-trails --region $aws_region --query trailList[].Name --output text`
    for trail in $trails; do
      # Check CloudTrail has a CloudWatch Logs group enabled
      total=`expr $total + 1`
      check=`aws cloudtrail describe-trails --region $aws_region --trail-name-list $trail |grep CloudWatchLogsLogGroupArn`
      if [ ! "$check" ]; then
        insecure=`expr $insecure + 1`
        echo "Warning:   CloudTrail $trail does not have a CloudWatch Logs group enabled [$insecure Warnings]"
      else
        secure=`expr $secure + 1`
        echo "Secure:    CloudTrail $trail has a CloudWatch Logs group enabled [$secure Passes]"
      fi
      # Check CloudTrail bucket is receiving logs
      total=`expr $total + 1`
      check=`aws cloudtrail get-trail-status --region $aws_region --name $bucket --query "LatestCloudWatchLogsDeliveryTime" --output text`
      if [ ! "$check" ]; then
        insecure=`expr $insecure + 1`
        echo "Warning:   CloudTrail $trail does not have a Last log file delivered timestamp [$insecure Warnings]"
      else
        secure=`expr $secure + 1`
        echo "Secure:    CloudTrail $trail has a last log file delivered timestamp [$secure Passes]"
      fi
      # Check CloudTrail has key enabled for bucket
      total=`expr $total + 1`
      check=`aws cloudtrail get-trail-status --region $aws_region --name $bucket| grep KmsKeyId`
      if [ ! "$check" ]; then
        insecure=`expr $insecure + 1`
        echo "Warning:   CloudTrail $trail does not have a KMS Key ID [$insecure Warnings]"
      else
        secure=`expr $secure + 1`
        echo "Secure:    CloudTrail $trail has a KMS Key ID [$secure Passes]"
      fi
    done
  else
    total=`expr $total + 1`
    secure=`expr $secure + 1`
    echo "Warning:   CloudTrail is not enabled [$secure Passes]"
  fi
}

