#
# Configure AWS credentials
#
AwsSettings.instance do |aws|
  Aws.config.update({
    region: aws.region,
    credentials: Aws::Credentials.new(aws.id, aws.secret)
  })
end
