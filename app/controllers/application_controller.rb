class ApplicationController < ActionController::Base
  EZGATE_HOST = "localhost"
  KANNEL_HOST = "localhost"
  KANNEL_SENDER_USERNAME = "ezgate"
  KANNEL_SENDER_PASSWORD = "ezgate"
  KANNEL_SMSBOX_PORT = "4041"
  KANNEL_SEND_SMS_PORT = "4042"
  KANNEL_ADMIN_PORT = "4040"
  KANNEL_ADMIN_PASSWORD = "ez@kannel*"
  RINGTONES_PATH = "/home/ezgate/ringtones"

  protect_from_forgery
  private
  
  def authorize
    unless UserDetail.find_by_id(session[:user_id])
      session[:original_uril] = request.url
      flash[:notice] = "Please log in"
      redirect_to root_url
    end
  end

  def role_authorize
    unless ["SA", "Administrator"].include?(session[:user_type])
      session[:original_uril] = request.url
      flash[:notice] = "Insuffiscient privileges!"
      redirect_to root_url
    end
  end

  def role_moderator
    unless ["SA", "Administrator","Service-Aggregator","Bulk-push"].include?(session[:user_type])
      session[:original_uril] = request.url
      flash[:notice] = "Insuffiscient privileges!"
      redirect_to root_url
    end
  end
end
