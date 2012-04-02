require 'csv'
class ContactsController < ApplicationController
	before_filter :authorize
	before_filter :role_moderator, :except => [:index,:send_sms,:view_directory,:search_directory]
	include REXML
  
	def index
		@contacts = Contact.where("user_id = '#{session[:user_id]}'")
		@groups = Group.where("user_id = '#{session[:user_id]}'", :order => "name")
    @directories = Directory.where("user_id='#{session[:user_id]}'").group("directory_ref")
	end

	def new_contact
		@group = Group.where("user_id = '#{session[:user_id]}'")
		if @group.nil?
			Group.create(:user_id => session[:user_id], :name => "default", :created_at => Time.now())
		end
		@contact = Contact.new(params[:contact])
    if request.post? and @contact.save
      flash[:notice] = "Contact #{@contact.name} successfuly added" 
      redirect_to(:action => "index")
    end		
	end

	def edit_contact		
    @contact = Contact.find(params[:id])
	end

	def update_contact
		@contact = Contact.find(params[:id])
		if @contact.update_attributes(params[:contact])
			flash[:notice] = "Contact #{@contact.name} successfuly updated!"
			redirect_to :action => "index"
		end
	end

	def new_group
		@group = Group.new(params[:group])
    if request.post? and @group.save
      flash[:notice] = "Group #{@group.name} successfuly added" 
      redirect_to(:action => "index")
    end		
	end

	def receive_drop		
		@contact = Contact.find(params[:id])
		@group = Group.find(params[:drop_id])
		@contact.update_attribute(:group_id, @group.id)
		
		@contacts = Contact.paginate :per_page => 30, 
      :conditions => "user_id = '#{session[:user_id]}'", :page => params[:page],
      :order => 'name'
		
		@groups = Group.find(:all, :conditions => "user_id = '#{session[:user_id]}'", :order => "name")
		
	  message = "Contact #{@contact.name} added to group #{@group.name}"
	  render :update do |page|  
	  	page.replace_html "update", :partial => "contacts" 
	  	#page.call 'location.reload'  
      page.replace_html("result", message )
      page["result"].visual_effect :highlight, :duration => 4
      page["result"].visual_effect :fade, :duration => 4
    end
	end

	def drop_group
		id = params[:id]
	  if id && group = Group.find(id)
	    begin
	      group.destroy
	      message = "Group #{group.name} dropped!"
	    rescue Exception => e
	      message = e.message
	    end
	  end
		@contacts = Contact.where("user_id = '#{session[:user_id]}'").order('name')
		
		@groups = Group.where("user_id = '#{session[:user_id]}'").order("name")
		render :update do |page|  

      page.replace_html("result", message )
      page["result"].visual_effect :highlight, :duration => 4
      page["result"].visual_effect :fade, :duration => 4
    end
	end
	
	def manage_contacts
		case params[:manage]
    when "Delete" then
      if params[:contact_ids] != nil
        Contact.delete_all(:id => params[:contact_ids])
        message = "contact(s) deleted !!"
      else
        message = "Select contact(s) to delete!"
      end
    when "Add contact to" then
      if params[:group_select][:grp_id] != ""
        @group = Group.find(params[:group_select][:grp_id])
        Contact.update_all(["group_id=?", params[:group_select][:grp_id]], :id => params[:contact_ids])
        message = "#{params[:contact_ids]} contact(s) added to group #{@group.name}"
      else
        message = "Select group first!"
      end
    when "Send message" then
      o = 0
      contacts = ""
      case session[:user_type]
      when "SA" then
        short_code = params[:short]
      when "Administrator" then
        short_code = params[:short]
      when "Service-Aggregator" then
        short_code = session[:short_code]
      when "Bulk-push" then
        short_code = session[:short_code]
      end
				
      if !params[:contact_ids].nil?
        a = Contact.find(params[:contact_ids])
        stock = User.find(session[:user_id])
 				c_count = Contact.count(params[:contact_ids])
 				if stock.sms_stock >= c_count or stock.stock_limit == false
          a.each do |i|
            contacts = contacts + i.phone_no.to_s
            sleep 1
            o = o + 1
            puts "Sending message no : #{o} ...."
            self.send_sms(params[:multi][:content], i.phone_no, short_code)
          end
        else
		  		message = "Stock left : #{stock.sms_stock} (sms)"
		  	end			
      else
        message = "No contact selected"
      end
      message = "#{o} Message(s) sent to [#{contacts}] @ #{Time.now.strftime("%H:%M:%S %Y-%m-%d")}"
		end
		flash[:notice] = message
		redirect_to :action => "index"
		
	end
	

  
  def send_sms(message, phone_no, short_code)
    @message = CGI::escape(message)
    @destination = phone_no.strip()
    url = URI.parse('http://127.0.0.1:13013')
    @resp_url = CGI::escape("http://127.0.0.1:3000/service_manager/record_push?incoming_id=0&user_id=#{session[:user_id]}&service=push&dest=#{@destination}&sender=#{short_code}&content=#{@message}&smsc=%i&status=%d")
    @http = Net::HTTP.new(url.host, url.port)
    puts "***********************************************************************"
    puts "******************* Sending message via SMS Gateway *******************"
    puts "***********************************************************************";
    puts "To : #{@destination}"
    puts "Message content : \n#{@message}";
    sms_gateway_response = @http.request_get("/cgi-bin/sendsms?username=pivot&password=pivot&from=#{short_code}&to=#{@destination}&text=#{@message}&dlr-mask=31&dlr-url=#{@resp_url}")
    puts 
    return "Response from SMS Gateway : \n#{sms_gateway_response.body}"
  end
  
  def check_gateway_status
  	status = 0
		begin
			parsed_html = Hpricot(open("http://127.0.0.1:13000/status.html?password=xobk09"))
			status = 1
			url = URI.parse('http://127.0.0.1:13000')
	  	http = Net::HTTP.new(url.host, url.port)
	  	gateway = http.request_get("/status.xml?password=pivot10")
	  	gateway_status = Document.new Iconv.conv("UTF-8//Ignore", 'UTF-8', gateway.body)
	  	box_status = gateway_status.elements["/gateway/status"].text 
	  	box_con = gateway_status.elements["/gateway/boxes/box/status"].text unless gateway_status.elements["/gateway/boxes/box/status"].nil?
	  	box = box_con.slice(0, 8) unless box_con.nil?
	  	curr_status = box_status.slice(0, 8)
	  	curr_status = curr_status.delete(',')
		rescue Errno::ECONNREFUSED
			status = 0
		rescue Errno::ECONNRESET
			status = 0	  
	  end
	  return status, curr_status, box
  end

	def csv_import
		begin
			group = params[:dump][:grp_id]
		  @parsed_file=CSV::Reader.parse(params[:dump][:file])
		  n=0
		  @parsed_file.each  do |row|
			  c=Contact.new
			  c.user_id= session[:user_id]
			  c.group_id = group
			  c.name = row[0]
			  c.phone_no= row[1].strip()
			  if c.save
			    n=n+1
			    GC.start if n%50==0
			  end
			end
		  message = "#{n} contact(s) imported successfuly !!"
	  rescue Exception 
	    message = "An error occured, please check the format of the file or its content!"
	  end
	  redirect_to :action => "index"
	  flash[:notice] = message
	end

  def new_directory
    if request.post?
      inserts = []
      row1,row2,row3,row4,row5,row6 = ""
      conn = ActiveRecord::Base.connection
      begin
        CSV.foreach(params[:directory][:file].tempfile,:col_sep => "\t") do |row|
          row1 = row[0].gsub(/\"|\'/,'') unless row[0].nil?
          row2 = row[1].gsub(/\"|\'/,'') unless row[1].nil?
          row3 = row[2].gsub(/\"|\'/,'') unless row[2].nil?
          row4 = row[3].gsub(/\"|\'/,'') unless row[3].nil?
          row5 = row[4].gsub(/\"|\'/,'') unless row[4].nil?
          row6 = row[5].gsub(/\"|\'/,'') unless row[5].nil?
          inserts.push "('#{session[:user_id]}', '#{params[:directory][:file].original_filename.gsub(/\"|\'/,'')}','#{row1}','#{row2}','#{row3}','#{row4}','#{row5}','#{row6}')"
        end
        sql = "INSERT INTO directories (user_id,directory_ref,row1,row2,row3,row4,row5,row6) VALUES #{inserts.join(',')}"
        conn.execute sql
        message = "File successfuly imported"
      rescue Exception => message
      end
      flash[:notice] = message
    end
    @directories = Directory.where("user_id='#{session[:user_id]}'").group("directory_ref")
  end

  def view_directory
    @directory = Directory.where("directory_ref='#{params[:id]}'")
  end

  def search_directory
    case params[:sel]
    when "col1" then
      @conditions = "user_id = #{session[:user_id]} and row1 LIKE '%#{params[:query1]}%'" unless params[:query1].nil?
    when "col2" then
      @conditions = "user_id = #{session[:user_id]} and row2 LIKE '%#{params[:query2]}%'" unless params[:query2].nil?
    when "col3" then
      @conditions = "user_id = #{session[:user_id]} and row3 LIKE '%#{params[:query3]}%'" unless params[:query3].nil?
    when "col4" then
      @conditions = "user_id = #{session[:user_id]} and row4 LIKE '%#{params[:query4]}%'" unless params[:query4].nil?
    end	
    @directory = Directory.where(@conditions).order('created_at DESC')
  end

  def delete_directory
    Directory.where(:directory_ref => params[:id] , :user_id => session[:user_id]).delete_all
    redirect_to :action => "index"
    flash[:notice] = "Directory #{params[:id]} deleted!"
  end
end
