# frozen_string_literal: true

##
# Handles all emails related to user accounts
#
# We tell [Devise](https://github.com/heartcombo/devise) to use this instead of
# [its own](https://github.com/heartcombo/devise/blob/main/app/mailers/devise/mailer.rb) in the
# `config/initializers/devise.rb`.
#
#   config.mailer = "UserMailer"
#
# Then where we are using Devise to handle a user function instead of calling its own mailer it will use ours instead.
# That is as long as we have implemented a method with the same name and signature.
#
# Of those the original team opted to use their own invitiation mail view and mailer. But they did use Devise for the
# forgotten password reset and unlock account functions.
#
# In all cases we need to add additional information to the object we pass through to `mail()` in order to get the
# information to `NotifyMail`. It will then use the template ID and personalisation when calling the Notify web API.
class UserMailer < ActionMailer::Base
  # When you generate Devise mailer views they will use Devise URL helpers. They differ in that they seem to generate
  # generic links rather than `user` specific. For example, the Rails `edit_user_password_url` will generate
  #
  # http://localhost:3001/auth/password/edit.10?reset_password_token=ncnfuszTvXMpAp_8gDBs
  #
  # The Devise `edit_password_url` will generate
  #
  # http://localhost:3001/auth/password/edit?reset_password_token=z8kHQ8eRx4SQ48kzkZpw
  #
  # It's a slight difference but it ensures we don't give away the user ID in the link. If you read the comments in
  # Devise::Controllers::UrlHelpers it states
  #
  # > In case you want to add such helpers to another class, you can do that as long as this new class includes both
  # > url_helpers and mounted_helpers.
  #
  # Thanks to https://stackoverflow.com/a/29887730/6117745 for giving us the clue which led to use getting
  # `edit_password_url()` working.
  include Rails.application.routes.url_helpers
  include Rails.application.routes.mounted_helpers
  include Devise::Controllers::UrlHelpers

  default from: ENV.fetch("DEVISE_MAILER_SENDER")

  def invitation(email, name, invitation_link)
    @email = email
    @name = name
    @link = invitation_link

    mail(
      to: email,
      subject: "Account created - SRoC Tactical Charging Module",
      template_id: "52f3a778-79b3-4de4-8939-9cccb52026a5",
      personalisation: {
        name: @name,
        link: @link,
        email: @email
      }
    )
  end

  def reset_password_instructions(record, token, opts={})
    @token = token
    @name = record.full_name
    @link = edit_password_url(record, reset_password_token: token)

    mail(
      to: record.email,
      subject: "Reset password - SRoC Tactical Charging Module",
      template_id: "427b45a3-3262-452d-b0b9-6302288f07dc",
      personalisation: {
        name: @name,
        link: @link
      }
    )
  end

  def unlock_instructions(record, token, opts={})
    @token = token
    @name = record.full_name
    @link = unlock_url(record, unlock_token: @token)

    mail(
      to: record.email,
      subject: "Unlock account - SRoC Tactical Charging Module",
      template_id: "aaea1a2f-4a9d-4aab-aaae-b672cb80e7b3",
      personalisation: {
        name: @name,
        link: @link
      }
    )
  end
end
