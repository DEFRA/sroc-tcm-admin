# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :cache_buster
  around_action :set_local_time
  before_action :authenticate_user!
  before_action :set_thread_current_user

  rescue_from StandardError do |e|
    TcmLogger.notify(e)
    raise e
  end

  private

  def read_only_user_check!
    if user_signed_in? && current_user.can_read_only?
      redirect_to root_path, notice: "You are not permitted to access this area or make changes to data."
    end
  end

  def export_data_user_check!
    if user_signed_in? && !current_user.can_export_data?
      redirect_to root_path, notice: "You are not permitted to export data from the system."
    end
  end

  def set_thread_current_user
    # this enables us to access the :current_user in models which is used in
    # auditing changes
    Thread.current[:current_user] = current_user if user_signed_in?
  end

  def set_local_time
    zone = Time.zone
    Time.zone = "Europe/London"
    yield
  ensure
    Time.zone = zone
  end

  def cache_buster
    # Cache buster, specifically we don't want the client to cache any
    # responses from the service
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate, private"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
