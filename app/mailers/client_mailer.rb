class ClientMailer < ActionMailer::Base
  default from: "dashboardsupport@getyella.com",
          delivery_method_options: {
            user_name: "<username>",
            password: "<password>"
          }

  def password_reset(client)
    @client = client
    mail(to: @client.email, 
         body: "Put content here",
         content_type: "text/html",
         subject: "Password Reset")
  end
end
