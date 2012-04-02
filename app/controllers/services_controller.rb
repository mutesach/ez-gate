class ServicesController < ApplicationController
	before_filter :authorize
	before_filter :role_authorize, :except => [:index,:list,:new_user_mod,:delete_mod_user,:add_service_mod,:remove_service_mod,
    :delete_user_service_mod, :reset_mod_password, :update_service_mod, :activate_user_mod, :deactivate_user_mod]
	before_filter :role_moderator
	def index
    case session[:user_type]
    when "SA" then
      conditions = ""
    when "Administrator" then
      conditions = ""
    when "Service-Aggregator" then
      conditions = "user_id = '#{session[:user_id]}'"
    when "Bulk-push" then
      conditions = "user_id = '#{session[:user_id]}'"
		end
		@services = Service.find(:all, :conditions => conditions)
		@user_mod = UserDetail.where("user_id='#{session[:user_id]}' and parent != 1").order('created_at DESC')

	end
	
	def list
		case session[:user_type]
    when "SA" then
      conditions = ""
    when "Administrator" then
      conditions = ""
    when "Service-Aggregator" then
      conditions = "user_id = '#{session[:user_id]}'"
    when "Bulk-push" then
      conditions = "user_id = '#{session[:user_id]}'"
		end
		@services = Service.find(:all, :conditions => conditions)
		@user_mod = UserDetail.where("user_id='#{session[:user_id]}' and parent != 1").order('created_at DESC')
		
	end
	
	def dynamic_codes	
		@user_short_codes = UserShortCode.find(:all)
	end
	
	def new_service
		@service = Service.new(params[:service])
		if @service.web_service_id == nil
			@service.web_service_id = 1
		end
    if request.post?

      user = UserShortCode.where("short_code_id=#{@service.user_short_code_id} and user_id=#{@service.user_id}").first
      if user
        if request.post? and @service.save
          flash[:notice] = "Service #{@service.name} successfuly created"
          redirect_to(:action => "list")
        end
      else
        flash[:notice] = "Please, first assign the short code to the user"
      end
      
    end
	end

	def new_user_mod
		@user_detail = UserDetail.new(params[:user_detail])
		if request.post? and @user_detail.save
			UserModService.create(
        :user_mod_id => @user_detail.id,
        :service_id => params[:user_mod_service][:service_id])
      flash[:notice] = "User #{@user_detail.username} created"
      redirect_to(:action => "list" )
    end
	end
	
	def delete_mod_user #delete a system user
	  id = params[:id]
	  if id && user = UserDetail.find(id)
	    begin
        user_detail = UserModService.find(:all, :conditions => "user_mod_id ='#{user.id}'")
        user_detail.each do |i|
          i.delete
        end
	      user.delete
	      flash[:notice] = "Moderator #{user.username} deleted"
	    rescue Exception => e
	      flash[:notice] = e.message
	    end
	  end
	  redirect_to(:action => :list)
  end
	
	def	add_service_mod
    @user_mod = UserDetail.find(params[:id]) unless params[:id].nil?
    @user_mod_service = UserModService.new(params[:user_mod_service])
    @service_mod_exists = nil
    if request.post? and @user_mod_service.save
      @service_mod_exists = UserModService.where("user_mod_id = #{params[:user_mod_service][:user_mod_id]} and service_id = #{params[:user_mod_service][:service_id]}")

      flash[:notice] = "Service added"

      redirect_to(:action => "index")
    end
  end
	
  def	remove_service_mod
    @user_mod = UserModService.where("user_mod_id=#{params[:id]}")
    sel = ''
    @user_mod.each do |i|
      sel = sel + "'" + i.service_id.to_s + "'" + ","
    end
    @sel = sel.slice(0, sel.length()-1)
    redirect_to(:action => "index")
    
  end
	
  def	delete_user_service_mod
    if request.xml_http_request?
      @user_service_mod = UserModService.find(:first, :conditions => "service_id=#{params[:user_mod_service][:service_id]}")
      @user_service_mod.delete
      case session[:user_type]
      when "SA" then
        conditions = ""
      when "Administrator" then
        conditions = ""
      when "Service-Aggregator" then
        conditions = "user_id = '#{session[:user_id]}'"
      when "Bulk-push" then
        conditions = "user_id = '#{session[:user_id]}'"
      end
      @services = Service.paginate :per_page => 50,
        :conditions => conditions, :page => params[:page],
        :order => 'created_at DESC'
      @user_mod = UserDetail.paginate :per_page => 50,
        :conditions => "user_id='#{session[:user_id]}' and parent != 1", :page => params[:page],
        :order => 'created_at DESC'
      render :partial => "list_services", :layout => false
    end
  end
	
  def update_service_mod

    @service_mod_exists = UserModService.find(:first, :conditions => "user_mod_id = #{@user_mod.id} and service_id = #{params[:user_mod_service][:service_id]}")
    if @service_mod_exists == nil
      UserModService.create(
        :user_mod_id => @user_mod.id,
        :service_id => params[:user_mod_service][:service_id])
      flash[:notice] = "Service added"
    else
      flash[:notice] = "Service already added!"
    end
    case session[:user_type]
    when "SA" then
      conditions = ""
    when "Administrator" then
      conditions = ""
    when "Service-Aggregator" then
      conditions = "user_id = '#{session[:user_id]}'"
    when "Bulk-push" then
      conditions = "user_id = '#{session[:user_id]}'"
    end
    @services = Service.paginate :per_page => 50,
      :conditions => conditions, :page => params[:page],
      :order => 'created_at DESC'
    @user_mod = UserDetail.paginate :per_page => 50,
      :conditions => "user_id='#{session[:user_id]}' and parent != 1", :page => params[:page],
      :order => 'created_at DESC'


  end
	
  def activate_user_mod
    @status = UserDetail.find(params[:id])
    @status.update_attribute(:status, true)
    flash[:notice] = "User #{@status.username} successfuly activated!"
    redirect_to :action => "list"
  end
 
  def deactivate_user_mod
    @status = UserDetail.find(params[:id])
    @status.update_attribute(:status, false)
    flash[:notice] = "User #{@status.username} successfuly deactivated!"
    redirect_to :action => "list"
  end

  def reset_mod_password
    @user = UserDetail.find_by_id(params[:id])
    new_password = UserDetail.random_password(6)
    @user.update_attribute(:password, new_password)
    flash[:notice] = "Password reset successfuly for user #{@user.username} : #{new_password}"
    redirect_to :action => "list"
  end

  def edit_service
    @service = Service.find(:first, :conditions => "id = '#{params[:id]}'")
  end
	
  def update_service
    @service = Service.find(params[:id])
    if @service.update_attributes(params[:service])
      redirect_to(:action => "list")
      flash[:notice] = "Service #{@service.name} successfuly updated"
    end
  end
	
  def enable_service
			
    @service = Service.find(params[:id])
    @service.update_attribute(:status, true)
    case session[:user_type]
    when "SA" then
      conditions = ""
    when "Administrator" then
      conditions = ""
    when "Service-Aggregator" then
      conditions = "user_id = '#{session[:user_id]}'"
    when "Bulk-push" then
      conditions = "user_id = '#{session[:user_id]}'"
    end
    @services = Service.where(conditions).order('created_at DESC')
    @user_mod = UserDetail.where("user_id='#{session[:user_id]}' and parent != 1").order('created_at DESC')
    flash[:notice] = "Service #{@service.name} successfuly activated !"
    redirect_to :action => "index"
			

  end
	
  def disable_service
				
    @service = Service.find(params[:id])
    @service.update_attribute(:status, false)
    case session[:user_type]
    when "SA" then
      conditions = ""
    when "Administrator" then
      conditions = ""
    when "Service-Aggregator" then
      conditions = "user_id = '#{session[:user_id]}'"
    when "Bulk-push" then
      conditions = "user_id = '#{session[:user_id]}'"
    end
    @services = Service.where(conditions).order('created_at DESC')
    @user_mod = UserDetail.where("user_id='#{session[:user_id]}' and parent != 1").order('created_at DESC')
    flash[:notice] = "Service #{@service.name} successfuly deactivated !"
    redirect_to :action => "index"

  end

  def disp_service
    @service = Service.find(params[:id])
    render :layout => false
  end
  
 
  def view_service_details
    @service = Service.find(:first, :conditions => "id = '#{$id}'")
    render :layout => false
  end
end
