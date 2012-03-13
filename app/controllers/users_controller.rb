class UsersController < ApplicationController
	before_filter :authorize
	before_filter :role_authorize
	
  def index #list system users
    #flash[:notice] = nil
    @users = User.find(:all)
  end
  
	def new_user
    @user = User.new(params[:user])
	end	
	
  def save_user
    @user = User.new(params[:user])
    @user_detail = UserDetail.new(params[:user_detail])
    #if params[:user][:short_code_id] == ""
    #	@user.short_code_id = 0
   	#end
    if request.post? and @user.save
      @user_detail.save
    	@user_detail.update_attribute(:user_id, @user.id)
    	Group.create(:user_id => @user.id, :name => "default", :created_at => Time.now())
      flash[:notice] = "User #{@user.name} created"
      redirect_to(:action => "index" )
    end
  end

  def delete_user #delete a system user
	  id = params[:id]
	  if id && user = User.find(id)
	    begin
        user_detail = UserDetail.find(:all, :conditions => "user_id ='#{user.id}'")
        user_detail.each do |i|
          i.delete
        end
	      user.delete
	      flash[:notice] = "User #{user.name} deleted"
	    rescue Exception => e
	      flash[:notice] = e.message
	    end
	  end
	  redirect_to(:action => :index)
  end 

  def edit_user
    @user = UserDetail.find(params[:id])
  end


	def edit_user_profile
    @user = User.find(params[:id])   
    @user_detail = UserDetail.find(:first, :conditions => "user_id='#{@user.id}' and parent=true") 

  end
  
  def update_user_profile
  	@user = User.find(params[:id])
  	@user_detail = UserDetail.find(:first, :conditions => "user_id='#{@user.id}' and parent=true") 
    if request.post?
    	@user.update_attribute(:user_type, params[:user][:user_type])
    	@user.update_attribute(:name, params[:user][:name])
    	@user_detail.update_attribute(:username, params[:user_detail][:username])
    	@user.update_attribute(:phone_no, params[:user][:phone_no])
    	@user.update_attribute(:email, params[:user][:email])
    	@user.update_attribute(:sms_limit, params[:user][:sms_limit])
    	@user.update_attribute(:sms_stock, params[:user][:sms_stock])
      flash[:notice] = "User successfully updated"
      redirect_to(:action => "index")
    else
      flash[:notice] = ""
      render :partial => "edit_user", :layout => true
    end
  end
  
  def change_password
    @user = UserDetail.find(params[:id])
    @expected_password = UserDetail.encrypted_password(params[:user_detail][:password], 
      @user.salt)
    if request.post? and @user.update_attributes(params[:user_detail])
      flash[:notice] = "Password successfully updated"
      redirect_to(:action => "index")
    else
      flash[:notice] = "Password doesn't match confirmation!"
    end
  end 

  def activate_user
    @status = UserDetail.find(params[:id])
    @status.update_attribute(:status, true)
    flash[:notice] = "User #{@status.user.name} successfuly activated!"
    @users = User.find(:all)
    redirect_to :action => "index"
  end
  
  def deactivate_user
    @status = UserDetail.find(params[:id])
    @status.update_attribute(:status, false)
    flash[:notice] = "User #{@status.user.name} successfuly deactivated!"
    @users = User.find(:all)
    redirect_to :action => "index"
  end
  
	def disp_user_profile 	
	 	if request.xml_http_request?	
	 		@user = User.find(:first, :conditions => "id = '#{params[:id]}'")
			render :partial => "disp_user_profile", :layout => false
		end
	end
	 
	def view_user_profile
		@user = User.find(:first, :conditions => "id = '#{params[:id]}'")
		short_codes = ShortCode.find(:all, :conditions => "user_short_codes.user_id = #{@user.id}",
      :joins => "left join user_short_codes on user_short_codes.short_code_id=short_codes.id",
      :select => "user_short_codes.user_id, short_codes.code, short_codes.id, short_codes.smsc, short_codes.sms_cost")
		code = ""
		short_codes.each do |i|
			code = code + "[" + i.code  + "] "
		end
	  @codes = code
		@services = Service.find(:all, :conditions => "user_id = '#{@user.id}'")
		@user_mod = UserDetail.find(:all, :conditions => "user_id= '#{@user.id}' and parent != 1")
					
		render :layout => false
	end 

end
