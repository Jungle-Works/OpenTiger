class BaseMandrillMailer < ActionMailer::Base
    default(
        from: "Yelo <contact@yelo.red>",
        reply_to: "Yelo <contact@yelo.red>"
     )
    def send_mail(email, subject, body)
        mail(to: email, subject: subject, body: body, content_type: "text/html")
    end
end

class UserMailer < BaseMandrillMailer
    module Mandrill
        module_function
        def reset_password(email, reset_token, community, person , isAdmin)
            @subject  = "Reset password"
            if isAdmin

              html = "<p>You have indicated that you have forgotten either your password or username in the %{service_name} service.</p><p>Your username is: %{username}</p><p>If you need to reset your password, then click <a href=%{password_reset_link}> here </a></p><br/><p>If you didn't request this, please ignore this email. Your password won't change until you access the link above and create a new one.</p>"
              body = html % {service_name:community.ident,username: person.username, password_reset_link: reset_token}
              BaseMandrillMailer.send_mail(email, @subject, body).deliver


            else  


              html = "<p>You have indicated that you have forgotten your password in  %{service_name} service.</p><p>Your username is: %{username}</p><p> Your new password is %{password_reset_link} </p><br><p>Click <a href=%{domain_url}>here</a> to login </p><br><p>You can change your password later by going to Settings > Account > Change Password </p>"
              body = html % {service_name:community.ident,username: person.username, password_reset_link: reset_token, domain_url: "https://" + community.ident + ".yelo.red/login"}
              BaseMandrillMailer.send_mail(email, @subject, body).deliver



            end
           
        end


        def new_listing_added(community,adminEmail,personemail,listingtitle,listinglink)

          begin

            begin
              @subject = " New Listing Added "
              html = "<p> Hey ! Greetings </p> <br> <p> New listing added to your marketplace %{community} <br> Listing Title: %{listingtitle} <br> Listing Author Email: %{personemail} <br> Click <a href=%{listinglink}>here</a> to access <br><br> Thanks <br> Team Yelo Rentals ."
              body = html % { community:community,listingtitle:listingtitle,personemail:personemail,listinglink:"https://" + listinglink}
              BaseMandrillMailer.send_mail(adminEmail,@subject,body).deliver
              return true
              
            rescue => exception
  
              return false
              
            end
  

          
          rescue


          end



        end

        def new_user_added(email,community,useremail)

          begin
            @subject = " New Signup on your community "
            html = "<p> Hey ! Greetings </p> <br> <p> There is a new signup with email address %{email} on your community %{community_name}</p> <br> Thanks <br> Team Yelo Rentals ."
            body = html % {email:useremail, community_name:community}
            BaseMandrillMailer.send_mail(email,@subject,body).deliver
            return true
            
          rescue => exception

            return false
            
          end

          return true
         

        end

        def send_invite_mails(email, code, community, message, person)

          @subject = "Invite new members"

          html = "<p>Hi!</p><p> %{inviter} has invited you to %{service_name}.</p>"

          if message.present?
            html += "Here is a personal message from %{inviter}: #{message}<br>"
          end

          html += "Join now"
        #   if code.present?
        #     html += "<br>Invitation code: %{code}"
        #   end
          body = html % {inviter: person["given_name"], service_name: "https://"+community["domain"], code: code}

          BaseMandrillMailer.send_mail(email, @subject, body).deliver
        end
    end
end
