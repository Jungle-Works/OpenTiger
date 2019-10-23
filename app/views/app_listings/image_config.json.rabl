object false
node(:message){"Action Complete"}
node(:status){200}



child @fields_final, :root => "data", :object_root => false do

    attributes :key,:acl,:signature,:policy,:success_action_status
    
    node(:AWSAccessKeyID){@fields.AWSAccessKeyId}
    node(:bucket_url){ @bucket_url}
    node(:aws_secret_access_key){ @aws_secret_access_key}
    node(:aws_access_key_id){ @aws_access_key_id}
    node(:bucket_url){ @bucket_url}
    node(:bucket_name) { @bucket }


end

