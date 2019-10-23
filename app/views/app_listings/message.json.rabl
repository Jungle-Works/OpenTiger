object false
node(:message){"Action Complete"}
node(:status){200}

child @message, :root => "data", :object_root => false do
    attributes :id,:content,:updated_at
   

    child :sender, :object_root => false do

    attributes :id,:image_url,:given_name

    end

   
end