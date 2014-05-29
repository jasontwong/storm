class ClientMailer < ActionMailer::Base
  include AbstractController::Callbacks

  default from: "Merchant Support<merchantsupport@getyella.com>"
  after_filter :set_delivery_options

  def password_reset(client)
    @client = client
    mail(to: @client.email, 
         body: "Reset your password here: https://clients.getyella.com/pass_reset?temp=" + @client.temp_password,
         content_type: "text/html",
         subject: "Password Reset")
  end

  private

  def set_delivery_options
    mail.delivery_method.settings.merge!({
      user_name: "merchantsupport@getyella.com",
      password: "4484LkKJKj"
    })
  end
end
