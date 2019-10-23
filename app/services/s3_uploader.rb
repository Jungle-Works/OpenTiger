class S3Uploader 

  def initialize()
    @aws_access_key_id = APP_CONFIG.aws_access_key_id
    @aws_secret_access_key = APP_CONFIG.aws_secret_access_key
    @bucket = APP_CONFIG.s3_upload_bucket_name
    @acl = "public-read"
    @expiration = 20.hours.from_now
  end

  def fields
    {
      :key => key,
      :acl => @acl,
      :policy => policy,
      :signature => signature,
      "AWSAccessKeyId" => @aws_access_key_id,
      :success_action_status => 200
    }
  end

  def url
    "https://#{@bucket}.s3-us-west-2.amazonaws.com/"
  end

  def landing_page_fields
    {
      "key" => landing_key,
      "acl" => @acl,
      "policy" => landing_policy,
      "signature" => landing_signature,
      "AWSAccessKeyId" => @aws_access_key_id,
      "success_action_status" => 200
    }
      
  end

  def checkout_page_fields
    {
      "key" => checkout_key,
      "acl" => @acl,
      "policy" => checkout_policy,
      "signature" => checkout_signature,
      "AWSAccessKeyId" => @aws_access_key_id,
      "success_action_status" => 200
    }
      
  end
  def signup_page_fields
    {
      "key" => signup_key,
      "acl" => @acl,
      "policy" => signup_policy,
      "signature" => signup_signature,
      "AWSAccessKeyId" => @aws_access_key_id,
      "success_action_status" => 200
    }
      
  end

  def profile_page_fields
    {
      "key" => profile_key,
      "acl" => @acl,
      "policy" => profile_policy,
      "signature" => profile_signature,
      "AWSAccessKeyId" => @aws_access_key_id,
      "success_action_status" => 200
    }

  end

  private

  def url_friendly_time
    Time.now.utc.strftime("%Y%m%dT%H%MZ")
  end

  def year
    Time.now.year
  end

  def month
    Time.now.month
  end

  def key
    "uploads/listing-images/#{year}/#{month}/#{url_friendly_time}-#{SecureRandom.hex}/${index}/${filename}"
  end

  def profile_key

    "images/people/images/"

  end
  

  def policy
    Base64.encode64(policy_data.to_json).gsub("\n", "")
  end

  

  def profile_policy
    Base64.encode64(policy_data_profile.to_json).gsub("\n", "")

  end
  def policy_data_profile

    {
      expiration: @expiration.utc.iso8601,
      conditions: [
        ["starts-with", "$key", "images/people/"],
        ["starts-with", "$Content-Type", "image/"],
        ["starts-with", "$success_action_status", "200"],
        ["content-length-range", 0, APP_CONFIG.max_image_filesize],
        {bucket: "yelodotred"},
        {acl: @acl}
      ]
    }

  end

  def policy_data
    {
      expiration: @expiration.utc.iso8601,
      conditions: [
        ["starts-with", "$key", "uploads/listing-images/"],
        ["starts-with", "$Content-Type", "image/"],
        ["starts-with", "$success_action_status", "200"],
        ["content-length-range", 0, APP_CONFIG.max_image_filesize],
        {bucket: @bucket},
        {acl: @acl}
      ]
    }
  end

 
  
  def url_friendly_time 
  Time.now.utc.strftime("%Y%m%dT%H%MZ") 
  end 
  
  def year 
  Time.now.year 
  end 
  
  def month 
  Time.now.month 
  end 
  
  def key 
  "uploads/listing-images/#{year}/#{month}/#{url_friendly_time}-#{SecureRandom.hex}/${index}/${filename}" 
  end 
  
  
  def landing_key 
  
  "landing/images/" 
  
  end 

  def checkout_key

    "checkout/images/"

  end
  def signup_key

    "signup/images/"

  end
  
  def policy 
  Base64.encode64(policy_data.to_json).gsub("\n", "") 
  end 
  
  def landing_policy 
  Base64.encode64(policy_data_landing.to_json).gsub("\n", "") 
  end 

  def checkout_policy 
    Base64.encode64(policy_data_checkout.to_json).gsub("\n", "") 
  end 
  
  def signup_policy 
    Base64.encode64(policy_data_signup.to_json).gsub("\n", "") 
  end 

  def policy_data_landing 
  { 
  expiration: @expiration.utc.iso8601, 
  conditions: [ 
  ["starts-with", "$key", "landing/images/"], 
  ["starts-with", "$Content-Type", "image/"], 
  ["starts-with", "$success_action_status", "200"], 
  ["content-length-range", 0, APP_CONFIG.max_image_filesize], 
  {bucket: @bucket}, 
  {acl: @acl} 
  ] 
  } 
  
  end 

  def policy_data_checkout
    { 
    expiration: @expiration.utc.iso8601, 
    conditions: [ 
    ["starts-with", "$key", "checkout/images/"], 
    # ["starts-with", "$Content-Type", "image/"], 
    ["starts-with", "$success_action_status", "200"], 
    ["content-length-range", 0, APP_CONFIG.max_image_filesize], 
    {bucket: @bucket}, 
    {acl: @acl} 
    ] 
    } 
    
  end 
  def policy_data_signup
    { 
    expiration: @expiration.utc.iso8601, 
    conditions: [ 
    ["starts-with", "$key", "signup/images/"], 
    # ["starts-with", "$Content-Type", "image/"], 
    ["starts-with", "$success_action_status", "200"], 
    ["content-length-range", 0, APP_CONFIG.max_image_filesize], 
    {bucket: @bucket}, 
    {acl: @acl} 
    ] 
    } 
    
  end 
  
  
  def policy_data 
  { 
  expiration: @expiration.utc.iso8601, 
  conditions: [ 
  ["starts-with", "$key", "uploads/listing-images/"], 
  ["starts-with", "$Content-Type", "image/"], 
  ["starts-with", "$success_action_status", "200"], 
  ["content-length-range", 0, APP_CONFIG.max_image_filesize], 
  {bucket: @bucket}, 
  {acl: @acl} 
  ] 
  } 
  end 
  
  def signature 
  Base64.encode64( 
  OpenSSL::HMAC.digest( 
  OpenSSL::Digest.new('sha1'), 
  @aws_secret_access_key, policy 
  ) 
  ).gsub("\n", "") 
  end 
  
  

  def profile_signature
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha1'),
        @aws_secret_access_key, profile_policy
      )
    ).gsub("\n", "")

  end

  def landing_signature
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha1'),
        @aws_secret_access_key, landing_policy
      )
    ).gsub("\n", "")

  end

  def checkout_signature
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha1'),
        @aws_secret_access_key, checkout_policy
      )
    ).gsub("\n", "")

  end
  def signup_signature
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha1'),
        @aws_secret_access_key, signup_policy
      )
    ).gsub("\n", "")

  end

  
end