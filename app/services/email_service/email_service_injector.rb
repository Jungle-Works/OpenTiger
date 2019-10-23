module EmailService::EmailServiceInjector
  def addresses_api
    @addresses ||= build_addresses_api()
  end

  def ses_client_instance
    @ses_client ||= build_ses_client()
  end

  def build_addresses_api
    EmailService::API::Addresses.new(
      default_sender: APP_CONFIG.sharetribe_mail_from_address,
      ses_client: build_ses_client()
    )
  end

  def build_ses_client
    if APP_CONFIG.aws_ses_region &&
       APP_CONFIG.aws_access_key_id &&
       APP_CONFIG.aws_secret_access_key
      EmailService::SES::Client.new(
        config: { region: "us-east-1",
                  access_key_id: "SDA",
                  secret_access_key: "ADA",
                  sns_topic: APP_CONFIG.aws_ses_sns_topic})
    else
      nil
    end
  end
end
