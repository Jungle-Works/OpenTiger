object false
node(:message){"Action Complete is"}
node(:status){200}

child @conversation,:root => "data", :object_root => false do


      
    attributes :id,:last_message_at,:starting_page

    node(:other_party) { |a| a.other_party_my_hsh(@my_id)  }

    child :last_message, :object_root => false do

    attributes :id,:content

    end
end
