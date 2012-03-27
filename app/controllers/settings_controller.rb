require 'net/http'
require 'rexml/document'
require 'iconv'
require 'rexml/document'
class String
	def not_needed?
		self.strip == "</p>" ? true : false
	end
end
class SettingsController < ApplicationController
	include REXML
	before_filter :authorize
	#before_filter :role_moderator
	before_filter :role_authorize
	#before_filter :role_authorize
	def index
		@status = 0
    @user_short_codes = UserShortCode.order('created_at DESC')
    @short_codes = ShortCode.order('created_at DESC')
    @web_services = WebService.order('created_at DESC')
    @ringtones = Ringtone.order('keyword DESC')
		#flash[:notice] = nil
		begin
			@status = 1
			url = URI.parse("http://#{KANNEL_HOST}:#{KANNEL_ADMIN_PORT}")
	  	@http = Net::HTTP.new(url.host, url.port)
	  	@gateway = @http.request_get("/status.xml?password=#{KANNEL_ADMIN_PASSWORD}")
	  	@gateway_status = Document.new Iconv.conv("UTF-8//Ignore", 'UTF-8', @gateway.body)
	  	@box_status = @gateway_status.elements["/gateway/status']"].text 
	  	@curr_status = @box_status.slice(0, 8)
	  	@curr_status = @curr_status.delete(',')
	  	puts @curr_status
      
      @file = ""
      File.open("#{Dir.pwd}/config/kannel.conf", "r") do |infile|
        while (line = infile.gets)
          @file = @file + line
        end
      end
		rescue Errno::ECONNREFUSED
			@status = 0
		rescue Errno::ECONNRESET
			@status = 0
    rescue Errno::ENOENT
      @status = 0
	  end		

		
	end
	
	def new_short_code
		@short_code = ShortCode.new(params[:short_code])
		@exists = ShortCode.where("code ='#{@short_code.code}' and smsc='#{@short_code.smsc}'").first
		if @exists.nil?
	    if request.post? and @short_code.save and @exists.nil?
	      flash[:notice] = "Short code #{@short_code.code} successfuly created" 
	      redirect_to(:action => "index")
	    end
	  else
	  	flash[:notice] = "Short code #{params[:short_code][:code]} already assigned to smsc #{@short_code.smsc}" 
	  end
	end
	
	def assign_short_code
		@user_short_code = UserShortCode.new(params[:user_short_code])
		@exists = UserShortCode.find(:first, :conditions => "short_code_id ='#{@user_short_code.short_code_id}' and user_id='#{@user_short_code.user_id}'")
		if @exists.nil?
	    if request.post? and @user_short_code.save
	      flash[:notice] = "Short code #{@user_short_code.short_code.code} successfuly assigned to #{@user_short_code.user.name}" 
	      redirect_to(:action => "index")
	    end
	  else
	  	flash[:notice] = "Short code #{params[:user_short_code][:code]} already assigned to user #{@user_short_code.user.name}" 
	  end
	end
	
	def edit_assigned_short_code
    @user_short_code = UserShortCode.find(params[:id])
	end
	
	def edit_short_code
    @short_code = ShortCode.find(params[:id])
	end
	
	def update_short_code
		@short_code = ShortCode.find(params[:id])
	  if @short_code.update_attributes(params[:short_code])	     
	    redirect_to(:action => "index")
	    flash[:notice] = "Short code #{@short_code.code} successfuly updated"
	  end
	end
	
	def update_assigned_short_code
		@user_short_code = UserShortCode.find(params[:id])
	  if @user_short_code.update_attributes(params[:user_short_code])	     
	    redirect_to(:action => "index")
	    flash[:notice] = "Assigned short code #{@user_hort_code.code} successfuly updated"
	  end
	end
	
	def delete_short_code 
	  id = params[:id]
	  if id && short_code = ShortCode.find(id)
	    begin
	      short_code.safe_delete
	      flash[:notice] = "Short code #{short_code.code} deleted"
	    rescue Exception => e
	      flash[:notice] = "Cannot delete short code #{short_code.code} : it is currently beeing used by one your users!!"
	    end
	  end
	  redirect_to(:action => :index)
  end

	
	def new_web_service
		@web_service = WebService.new(params[:web_service])
		if request.post? and @web_service.save
	    flash[:notice] = "Web service #{@web_service.name} successfuly created" 
	    redirect_to(:action => "index")
	  end
	end
	
	def edit_web_service
		@web_service = WebService.find(params[:id])   
	end
	
	def update_web_service
		@web_service = WebService.find(params[:id])
	  if @web_service.update_attributes(params[:web_service])	     
	    redirect_to(:action => "index")
	    flash[:notice] = "Web service #{@web_service.name} successfuly updated"
	  end
	end
	
	def delete_web_service
	  id = params[:id]
	  if id && web_service = WebService.find(id)
	    begin
	      web_service.safe_delete
	      flash[:notice] = "Web service #{web_service.name} deleted"
	    rescue Exception => e
	      flash[:notice] = e.message
	    end
	  end
	  redirect_to(:action => :index)
  end 
	
	def activate_short_code
    @short_code = ShortCode.find(params[:id])
    @short_code.update_attribute(:status, true)
    @short_codes = ShortCode.order('created_at DESC')
    @user_short_codes = UserShortCode.order('created_at DESC')
    flash[:notice] = "Short code #{@short_code.code} successfuly enabled !"
    redirect_to :action => "index"
	end	
	
	def deactivate_short_code
					
    @short_code = ShortCode.find(params[:id])
    @short_code.update_attribute(:status, false)
    @short_codes = ShortCode.order('created_at DESC')
    @user_short_codes = UserShortCode.order('created_at DESC')
    flash[:notice] = "Short code #{@short_code.code} successfuly disabled !"
    redirect_to :action => "index"
	end
  
	def resume_kannel
		url = URI.parse('http://127.0.0.1:13000')
	  @http = Net::HTTP.new(url.host, url.port)
	  sms_gateway_response = @http.request_get("/resume?password=pivot10")
		redirect_to :action => "index"
	end
	
	def isolate_kannel
		url = URI.parse('http://127.0.0.1:13000')
	  @http = Net::HTTP.new(url.host, url.port)
	  sms_gateway_response = @http.request_get("/isolate?password=pivot10")
		redirect_to :action => "index"
	end
	
	def restart_kannel
		url = URI.parse('http://127.0.0.1:13000')
	  @http = Net::HTTP.new(url.host, url.port)
	  sms_gateway_response = @http.request_get("/restart?password=pivot10")
	  system "sleep 5"
		redirect_to :action => "index"
	end
	
	def start_kannel
    Net::SSH.start("10.121.30.5", "pivot", :password => "guka9sym") do |ssh|
      ssh.exec! "/etc/init.d/kannel start"
    end
    redirect_to :action => "index"
  end

  def update_kannel_conf
    if params[:button_update] == "Update"
      File.open("#{RAILS_ROOT}/config/kannel.conf", 'w') {|f| f.write(params[:kannel][:kannel_conf]) }
      result = self.upload_file("#{RAILS_ROOT}/config/kannel.conf")
      redirect_to :action => "index"
      flash[:notice] = result.to_s
    else
      redirect_to :action => "index"
    end
  end

  def upload_file(file)
    local_file = file
    remote_file = '/etc/kannel.conf'
    res = ""
    puts 'Connecting to remote server'
    begin
      Net::SFTP.start('10.121.30.5', 'pivot', :password => 'guka9sym') do |sftp|
        # upload a file or directory to the remote host
        begin
          puts "Uploading file to #{remote_file}"
          sftp.upload!(local_file, remote_file)
          res = "Configuration file updated successfully!"
        rescue Net::SFTP::StatusException => e
          raise unless e.code == 2
          res = e
        end
      end
    rescue Errno::ENETUNREACH => f
	    res = f
    end
    res
	end

  def new_ringtone
    if request.post?
      begin
        import_file = params[:ringtone][:f_name].tempfile
        file_name = params[:ringtone][:f_name].original_filename.gsub(" ", "-")
        save_as = File.join(RINGTONES_PATH ,  file_name)
        File.open(save_as.to_s,'wb' ) do |file|
          file.write( import_file.read )
        end
        extension = File.extname(params[:ringtone][:f_name].original_filename).sub( /^\./, '' ).downcase
        size = File.size(save_as)

        ringtone = Ringtone.create(:user_id => session[:user_id],
          :keyword => 1,
          :aliases => 1,
          :song_title => params[:ringtone][:song_title],
          :artist_name => params[:ringtone][:artist_name],
          :f_name => file_name,
          :f_extension => extension,
          :f_size => size,
          :f_path => RINGTONES_PATH,
          :status => 0)
        ringtone.update_attribute(:keyword, ringtone.id)
        ringtone.update_attribute(:aliases, ringtone.id)
        message = "Ringtone created successfuly"
      rescue Errno::ENOENT => message
      rescue Errno::EACCES => message
      end

      flash[:notice] = message    
      redirect_to :action => "index"
    end    
  end
  
  def edit_ringtone
    @ringtone = Ringtone.find(params[:id])
  end

  def update_ringtone
    @ringtone = Ringtone.find(params[:id])
    @ringtone.aliases = params[:ringtone][:keyword]
	  if @ringtone.update_attributes(params[:ringtone])
	    redirect_to(:action => "index")
	    flash[:notice] = "Ringtone #{@ringtone.song_title} successfuly updated"
	  end
  end

  def activate_ringtone
    @ringtone = Ringtone.find(params[:id])
    @ringtone.update_attribute(:status, true)
    redirect_to :action => "index"
    flash[:notice] = "Ringtone #{@ringtone.keyword} enabled"

  end

  def deactivate_ringtone
    @ringtone = Ringtone.find(params[:id])
    @ringtone.update_attribute(:status, false)
    redirect_to :action => "index"
    flash[:notice] = "Ringtone #{@ringtone.keyword} disabled"
  end

  def delete_ringtone
	  id = params[:id]
	  if id && ringtone = Ringtone.find_by_id(id)
	    begin
        File.delete "#{ringtone.f_path}/#{ringtone.f_name}"
	      ringtone.delete
	      flash[:notice] = "Ringtone #{ringtone.song_title} deleted"
	    rescue Exception => e
	      flash[:notice] = "Cannot delete #{ringtone.song_title} : it is currently beeing used by one your users!!"
	    end
	  end
	  redirect_to(:action => :index)
  end

  def view_ringtones
    @ringtones = Ringtone.all
  end
end
