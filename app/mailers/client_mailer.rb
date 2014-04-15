class ClientMailer < ActionMailer::Base
  include AbstractController::Callbacks

  default from: "Support<support@getyella.com>"
  after_filter :set_delivery_options

  def password_reset(client)
    @client = client
    mail(to: @client.email, 
         body: "Put content here",
         content_type: "text/html",
         subject: "Password Reset")
  end

  private

  def set_delivery_options
    mail.delivery_method.settings.merge!({
      user_name: "<email>",
      password: "<password>"
    })
  end
end
