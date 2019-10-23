object false
node(:message){"Action Complete"}
node(:status){200}
child @messages, :root => "data", :object_root => false do
    node(:content) {|a| a[:content]}
    node(:trx_status) { @transaction.present? ? @transaction.current_state : ""}
    node(:updated_at) {|a| a[:created_at]}
    node(:id) {""}
    node(:person) {|a| a[:sender].msg_hsh}
end