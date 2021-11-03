# frozen_string_literal: true

Coverband.configure do |config|
  # Experimental support for tracking view layer tracking.
  # Does not track line-level usage, only indicates if an entire file
  # is used or not.
  config.track_views = true
end
