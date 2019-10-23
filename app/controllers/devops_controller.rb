class DevopsController < ActionController::Base


    def ping
        hsh = HashWithIndifferentAccess.new
          hsh[:message] = "Successful"
          hsh[:status] = "200"
          hsh[:data] = {}
          render :json => hsh.to_json  
      end
end