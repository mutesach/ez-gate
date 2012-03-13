class LoginController < ApplicationController
  before_filter :authorize, :except => :login
  #filter_parameter_logging :username
  #filter_parameter_logging :password

  def index
  end

  def login
    session[:user_id] = nil
    if request.post?
      user = UserDetail.authenticate(params[:username], params[:password])
      if user
      	if user.parent == true
          session[:user_id] = user.user.id
          session[:user_type] = user.user.user_type
          session[:name] = user.user.name
          short_codes = ShortCode.select("user_short_codes.user_id, short_codes.code, short_codes.id").joins("left join user_short_codes on user_short_codes.short_code_id=short_codes.id").where("user_short_codes.user_id = #{session[:user_id]}")
          code = ""
          short_codes.each do |i|
            code = code + "[" + i.code  + "] "
          end
          session[:short_code] = code
        else
          session[:user_id] = user.id
          session[:user_type] = "Moderator"
          session[:parent] = user.user.id
          session[:name] = user.username
        end
        if user.status == true
	        redirect_to(:controller => "messages", :action => "index")
	      else
	      	redirect_to(:action => "login")
	      	flash[:notice] = "User inactive, contact your sys. administrator"
	      end
      else
        flash[:notice] = "Invalid user/password combination"
      end
    end
  end

  def logout
    reset_session
    flash[:notice] = "Logged out"
    redirect_to root_url
  end

end
