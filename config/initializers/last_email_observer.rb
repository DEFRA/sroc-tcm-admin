# frozen_string_literal: true

class LastEmailObserver

  def self.delivered_email(message)
    LastEmailCache.instance.last_email = message
  end

end

ActionMailer::Base.register_observer(LastEmailObserver)
