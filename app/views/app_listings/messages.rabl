object false
node(:message){"Action Complete"}
node(:status){200}
node(:data){Conversation.all_conversation_hsh(@participations, @current_community, @person)}