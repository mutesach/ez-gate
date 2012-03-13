class ApplicationController < ActionController::Base
  EZGATE_HOST = "localhost:3001"
  KANNEL_HOST = "localhost"
  KANNEL_SENDER_USERNAME = "ezgate"
  KANNEL_SENDER_PASSWORD = "ezgate"
  KANNEL_SMSBOX_PORT = "4041"
  KANNEL_SEND_SMS_PORT = "4042"
  KANNEL_ADMIN_PORT = "4040"
  KANNEL_ADMIN_PASSWORD = "ez@kannel*"
  RINGTONES_PATH = "/home/ezgate/ringtones"

  protect_from_forgery


  layout :detect_browser

  private
  MOBILE_BROWSERS = ["android", "ipod", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

  def detect_browser
    agent = request.headers["HTTP_USER_AGENT"].downcase
    MOBILE_BROWSERS.each do |m|
      return "mobile_application" if agent.match(m)
    end
    return "application"
  end

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
