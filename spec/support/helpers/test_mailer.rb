# frozen_string_literal: true

class TestMailer < ActionMailer::Base

  FROM_ADDRESS = "defra-ruby-email@example.com"

  def multipart_email(recipient)
    mail(
      to: recipient,
      from: FROM_ADDRESS,
      subject: "Multi-part email"
    ) do |format|
      format.html { render html: "<h1>This is the html version of an email</h1>".html_safe }
      format.text { render plain: "This is the text version of an email" }
    end
  end

  def html_email(recipient)
    mail(
      to: recipient,
      from: FROM_ADDRESS,
      subject: "HTML email"
    ) do |format|
      format.html { render html: "<h1>This is the html version of an email</h1>".html_safe }
    end
  end

  def text_email(recipient)
    mail(
      to: recipient,
      from: FROM_ADDRESS,
      subject: "Text email"
    ) do |format|
      format.text { render plain: "This is the text version of an email" }
    end
  end
end
