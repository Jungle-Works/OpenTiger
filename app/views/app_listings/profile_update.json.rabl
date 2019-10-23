object false
node(:message){"Action Complete"}
node(:status){200}
child @person, :root => "data", :object_root => false do
    attributes :image_url
end