require 'net/http'
require 'rexml/document'
require 'iconv'
require 'rexml/document'
class MessagesController < ApplicationController
	before_filter :authorize
	before_filter :role_moderator, :except => ["index","inbound","update_inbound",
    "search_by_service","search_by_content","search_by_destination","search_by_date",
    "search_by_sender", "convert_date", "filter_by", "view_inbound_message",
    "disp_inbound_message"]
	include REXML
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
    when "Moderator" then
      @user_mod = UserModService.where("user_mod_id=#{session[:user_id]}")
      sel = ''
      conditions = ''
      @user_mod.each do |i|
			 	sel = sel + "'" + i.service_id.to_s + "'" + ","
      end
      sel = sel.slice(0, sel.length()-1)
      conditions = "id in('#{sel}')" unless @user_mod.nil?
      conditions = "id in('')" unless sel != nil
      puts sel
		end
		@service =  Service.find(:all, :conditions => conditions)
	end
	
	def inbound
		case session[:user_type]
    when "SA" then
      conditions = ""
    when "Administrator" then
      conditions = ""
    when "Service-Aggregator" then
      conditions = "user_id = '#{session[:user_id]}'"
    when "Bulk-push" then
      conditions = "user_id = '#{session[:user_id]}'"
    when "Moderator" then
      @user_mod = UserModService.where("user_mod_id=#{session[:user_id]}")
      sel = ''
      conditions = ''
      @user_mod.each do |i|
			 	sel = sel + "'" + i.service_id.to_s + "'" + ","
      end
      sel = sel.slice(0, sel.length()-1)
      conditions = "service_id in(#{sel})" unless @user_mod.nil?
      conditions = "id in('')" unless sel != nil
		end
		@inbound_messages = InboundMessage.where(conditions).order("created_at DESC")
		@result = InboundMessage.where(conditions).count
	end
	
	
	def get_all
		if request.env["HTTP_USER_AGENT"] == "WS_PivotGate"
			user = UserDetail.authenticate(params[:login][:username], params[:login][:password])
			if user		    
				case user.user.user_type
        when "SA" then
          conditions = ""
        when "Administrator" then
          conditions = ""
        when "Service-Aggregator" then
          conditions = "user_id = '#{session[:user_id]}'"
        when "Bulk-push" then
          conditions = "user_id = '#{session[:user_id]}'"
        when "Moderator" then
          user_mod = UserModService.where("user_mod_id=#{session[:user_id]}")
          sel = ''
          conditions = ''
          user_mod.each do |i|
					 	sel = sel + "'" + i.service_id.to_s + "'" + ","
          end
          sel = sel.slice(0, sel.length()-1)
          conditions = "service_id in(#{sel})" unless user_mod.nil?
          conditions = "id in('')" unless sel != nil
				end
				@result = InboundMessage.where(@conditions).order('created_at DESC')
	    else
      	@result = self.xml_message("Invalid username/password combination")
      end
    else
    	@result = self.xml_message("Invalid USER-AGENT")
    end
    respond_to do |format|					
      format.xml  { render :xml => @result }			  	      
    end
	end
	
	def xml_message(message)
		xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.error { 
      xml.description(message)
    }
    return xml.target!
	end
	
	def outbound
		case session[:user_type]
    when "SA" then
      conditions = ""
    when "Administrator" then
      conditions = ""
    when "Service-Aggregator" then
      conditions = "user_id = '#{session[:user_id]}'"
    when "Bulk-push" then
      conditions = "user_id = '#{session[:user_id]}'"
    when "Moderator" then
      @user_mod = UserModService.where("user_mod_id=#{session[:user_id]}")
      sel = ''
      conditions = ''
      @user_mod.each do |i|
        keyword = Service.where("id=#{i.service_id}").select("keyword")
        sel = sel + "'" + keyword.keyword + "'" + ","
      end
      sel = sel.slice(0, sel.length()-1)
      conditions = "service in(#{sel}) or service='push'" unless @user_mod.nil?
		end
		@outbound_messages = OutboundMessage.where(conditions)
		@result = OutboundMessage.where(conditions).count
	end
	
	def update_inbound
		if request.xml_http_request?
			case session[:user_type]
      when "SA" then
        @conditions = ""
      when "Administrator" then
        @conditions = ""
      when "Service-Aggregator" then
        @conditions = "user_id = '#{session[:user_id]}'"
      when "Bulk-push" then
        @conditions = "user_id = '#{session[:user_id]}'"
      when "Moderator" then
				@user_mod = UserModService.where("user_mod_id=#{session[:user_id]}")
				sel = ''
				@conditions = ''
				@user_mod.each do |i|
          sel = sel + "'" + i.service_id.to_s + "'" + ","
				end
				sel = sel.slice(0, sel.length()-1)
				@conditions = "service_id in(#{sel})" unless @user_mod.nil?
				@conditions = "id in('')" unless sel != nil
			end
			@inbound_messages = InboundMessage.where(@conditions).order('created_at DESC')
			@result = InboundMessage.where(@conditions).count
			render :partial => "inbound_messages", :layout => false
		end
	end	
	
	def search_by_service		
		case params[:sel]
    when "in" then
      @service = Service.find(params[:query1]) unless params[:query1].nil?
      @conditions = ["user_id = #{session[:user_id]} and service_id = '#{params[:query1]}'"] unless params[:query1].nil?
      @conditions = ["service_id = '#{params[:query1]}'"] unless !["SA","Administrator"].include?(session[:user_type])
      if !["SA", "Administrator"].include?(session[:user_type])
        @conditions = ["service_id = '#{params[:query1]}' and user_id='#{session[:parent]}'"] unless params[:query1].nil?
      end
      @inbound_messages = InboundMessage.where(@conditions).order('created_at DESC')
      @result = InboundMessage.where(@conditions).count
    when "out" then
      @service = Service.find_by_keyword(params[:query1])
      @conditions = ["user_id = #{session[:user_id]} and service = '#{params[:query1]}'"] unless params[:query1].nil?
      @conditions = ["service = '#{params[:query1]}'"] unless !["SA","Administrator"].include?(session[:user_type])
      @outbound_messages = OutboundMessage.where(@conditions).order('created_at DESC')
      @result = OutboundMessage.where(@conditions).count
		end
	
	end
	
	def search_by_destination
		case params[:sel]
    when "in" then
      @conditions = ["user_id = #{session[:user_id]} and destination = '#{params[:query4]}'"] unless params[:query4].nil?
      @conditions = ["destination = '#{params[:query4]}'"] unless !["SA","Administrator"].include?(session[:user_type])
      @inbound_messages = InboundMessage.where(@conditions).order('created_at DESC')
      @result = InboundMessage.where(@conditions).count
    when "out" then
      @conditions = ["user_id = #{session[:user_id]} and destination LIKE?", "%#{params[:query4]}%"] unless params[:query4].nil?
      @conditions = ["destination LIKE ?" ,"%#{params[:query4]}%"] unless !["SA","Administrator"].include?(session[:user_type])
      @outbound_messages = OutboundMessage.where(@conditions).order('created_at DESC')
      @result = OutboundMessage.where(@conditions).count
		end
	end
	
	def convert_date(obj)
    return Date.new(obj['(1i)'].to_i,obj['(2i)'].to_i,obj['(3i)'].to_i)
  end
	
	def search_by_date
		params[:date_from] = self.convert_date(params[:date_from])
		params[:date_to] = self.convert_date(params[:date_to])
		case params[:sel]
    when "in" then
      @conditions = "user_id = #{session[:user_id]} and date(created_at) >= '#{params[:date_from]}' and date(created_at) <= '#{params[:date_to]}'"
      @conditions = "date(created_at) >= '#{params[:date_from]}' and date(created_at) <= '#{params[:date_to]}'" unless !["SA","Administrator"].include?(session[:user_type])
      @inbound_messages = InboundMessage.where(@conditions).order('created_at DESC')
      @result = InboundMessage.where(@conditions).count
    when "out" then
      @conditions = "user_id = #{session[:user_id]} and date(created_at) >= '#{params[:date_from]}' and date(created_at) <= '#{params[:date_to]}'"
      @conditions = "date(created_at) >= '#{params[:date_from]}' and date(created_at) <= '#{params[:date_to]}'" unless !["SA","Administrator"].include?(session[:user_type])
      @outbound_messages = OutboundMessage.where(@conditions).order('created_at DESC')
      @result = OutboundMessage.where(@conditions).count
		end	
	end
		
	def search_by_sender
		case params[:sel]
    when "in" then
      @conditions = ["user_id = #{session[:user_id]} and sender LIKE ?", "%#{params[:query2]}%"] unless params[:query2].nil?
      @conditions = ["sender LIKE ?", "%#{params[:query2]}%"] unless !["SA","Administrator"].include?(session[:user_type])
      @inbound_messages = InboundMessage.where(@conditions).order('created_at DESC')
      @result = InboundMessage.where(@conditions).count
    when "out" then
      @conditions = ["user_id = #{session[:user_id]} and sender = #{params[:query2]}"] unless params[:query2].nil?
      @conditions = ["sender = '#{params[:query2]}'"] unless !["SA","Administrator"].include?(session[:user_type])
      @outbound_messages = OutboundMessage.where(@conditions).order('created_at DESC')
      @result = OutboundMessage.where(@conditions).count
		end
	end
	
	def search_by_content
		case params[:sel]
    when "in" then
      @conditions = ["user_id = #{session[:user_id]} and content LIKE ?", "%#{params[:query3]}%"] unless params[:query3].nil?
      @conditions = ["content LIKE ?", "%#{params[:query3]}%"] unless !["SA","Administrator"].include?(session[:user_type])
      @inbound_messages = InboundMessage.where(@conditions).order('created_at DESC')
      @result = InboundMessage.where(@conditions).count
    when "out" then
      @conditions = ["user_id = #{session[:user_id]} and content LIKE ?", "%#{params[:query3]}%"] unless params[:query3].nil?
      @conditions = ["content LIKE ?", "%#{params[:query3]}%"] unless !["SA","Administrator"].include?(session[:user_type])
      @outbound_messages = OutboundMessage.where(@conditions).order('created_at DESC')
      @result = OutboundMessage.where(@conditions).count
		end
	end
	
	def filter_by
		case params[:filter]
    when nil then group = ""
    when "smsc" then group = "smsc"
    when "service" then group = "service_id"
    when "sender" then group = "sender"
    when "status" then group = "service_status"
    when "date_time" then group = "date(created_at)"
		end
		@inbound_messages = InboundMessage.where(params[:cond]).select("count(*) as num, smsc, service_id, sender, service_status, read_status,created_at").group(group).order("num DESC")
		if request.xml_http_request?
			render :partial => "filtered_by_#{params[:filter]}", :layout => false
		end
	end
  
 
  def view_inbound_message
    @inbound_message = InboundMessage.where("id = '#{params[:id]}'").first
    @outbound_message = OutboundMessage.where("inbound_id = '#{params[:id]}'").first
    render :layout => false
  end
 
  def view_outbound_message
    @outbound_message = OutboundMessage.where("id = '#{params[:id]}'").first
    render :layout => false
  end
 
  def new_message
    @result = self.check_gateway_status()
    @status = @result[0]
    @curr_status = @result[1]
    @box_status = @result[2]
  end

  def compose_new_message
    @result = self.check_gateway_status()
    @status = @result[0]
    @curr_status = @result[1]
    @box_status = @result[2]
    render :layout => false
  end
  
  def send_message
    destination = ShortCode.find(params[:message][:dest])


    stock = User.find(session[:user_id])
    if stock.sms_stock > 0 or stock.sms_limit == false
      result = self.send_sms(params[:message][:content], params[:message][:phone_single], destination)
      if !["400","503","403"].include?(result[0])
        stock.update_attribute(:sms_stock, stock.sms_stock - 1) unless stock.sms_limit == false
        message = "1 Message(s) sent to #{params[:message][:phone_single]} @ #{Time.now.strftime("%H:%M:%S %Y-%m-%d")}"
      else
        message = result[1]
      end
         
    else
      message = "Unable to send message(s), stock : #{stock.sms_stock} (sms)"
    end

    
    redirect_to :action => "new_message"
    flash[:notice] = message

  end

  def single_message_box
    if request.xml_http_request?
      @contact = Contact.find(params[:id])
			render :partial => "single_message_box", :layout => false
		end
  end
 
  def reply_message_box
    if request.xml_http_request?
      @phone_no = params[:id]
			render :partial => "reply_message_box", :layout => false
		end
  end
 
  def reply_message
    @result = self.check_gateway_status()
    @status = @result[0]
    @curr_status = @result[1]
    @box_status = @result[2]
    @user = User.find(session[:user_id])
    render :layout => false
  end
  
  def multi_message_box
    @user = User.find(session[:user_id])
    @group = Group.find(params[:id])
    render :layout => false
  end
 
  def multi_sel_message_box
    if request.xml_http_request?
      @group = Group.find(params[:id])
			render :partial => "multi_sel_message_box", :layout => false
		end
  end
 
  def single_message
    @result = self.check_gateway_status()
    @status = @result[0]
    @curr_status = @result[1]
    @box_status = @result[2]
    @user = User.find(session[:user_id])
    render :layout => false
  end
 
  def multi_message
    @result = self.check_gateway_status()
    @status = @result[0]
    @curr_status = @result[1]
    @box_status = @result[2]
    @user = User.find(session[:user_id])
    render :layout => false
  end
 
  def send_single_message
    @result = self.check_gateway_status()
    @status = @result[0]
    @curr_status = @result[1]
    @box_status = @result[2]

    if @status == 0
      message = "SMS Gateway not available"
    else
      if @curr_status == "running" and @box_status != nil
        stock = User.find(session[:user_id])
        if stock.sms_stock > 0 or stock.sms_limit == false
          result = self.send_sms(params[:content], params[:id], params[:short])
          if !["400","503"].include?(result[0])
            stock.update_attribute(:sms_stock, stock.sms_stock - 1) unless stock.sms_limit == false
            puts "Sending message to #{params[:id]} ...."
            message = "1 Message sent to #{params[:name]} [#{params[:id]}] @ #{Time.now.strftime("%H:%M:%S %Y-%m-%d")}"
          else
            message = result[1]
          end
        else
          message = "Unable to send message(s), stock : #{stock.sms_stock} (sms)"
        end
      else
        message = "SMS Box not available"
      end
    end
    render :update do |page|
      page.replace_html("result", message)
      page["result"].visual_effect :highlight, :duration => 4
    end
  end
  
  def send_multi_message
    @result = self.check_gateway_status()
    @status = @result[0]
    @curr_status = @result[1]
    @box_status = @result[2]
    if @status == 0
      message = "SMS Gateway not available"
    else
      if @curr_status == "running" and @box_status != nil
        stock = User.find(session[:user_id])
        contacts = Contact.count(:all, :conditions => "group_id='#{params[:id]}'")
        if stock.sms_stock >= contacts or stock.sms_limit == false
          o = 0
          @contacts = Contact.find(:all, :conditions => "group_id='#{params[:id]}'")
          @contacts.each do |i|
            result = self.send_sms(params[:content], i.phone_no, params[:short])
            if !["400","503"].include?(result[0])
              sleep 0.5
              o = o + 1
              puts "Sending message no : #{o} ...."
              stock.update_attribute(:sms_stock, stock.sms_stock - 1) unless stock.sms_limit == false
              message = "#{o} Message(s) sent to group [#{params[:name]}] @ #{Time.now.strftime("%H:%M:%S %Y-%m-%d")}"
            else
              message = result[1]
              break
            end
          end
		  			  	
        else
          message = "Unable to send message, stock : #{stock.sms_stock} (sms)"
        end
      else
        message = "SMS Box not available"
      end
    end
    render :update do |page|
      page.replace_html("result", message)
      page["result"].visual_effect :highlight, :duration => 4
    end
  end
 
  def check_gateway_status
    status = 0
		begin
			status = 1
			url = URI.parse("http://#{KANNEL_HOST}:#{KANNEL_ADMIN_PORT}")
      http = Net::HTTP.new(url.host, url.port)
      gateway = http.request_get("/status.xml?password=#{KANNEL_ADMIN_PASSWORD}")
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
    rescue Errno::ENOENT
      status = 0
    end
    return status, curr_status, box
  end

  def send_sms(message, phone_no, short_code)
    case short_code.smsc
    when "Vodacom DRC" then
      kannel_sender_username = "vodacomcongo"
      kannel_sender_password = "vodacomcongo"
    when "Tigo DRC" then
      kannel_sender_username = "tigocongo"
      kannel_sender_password = "tigocongo"
    when "Tigo Tchad" then
      kannel_sender_username = "tigotchad"
      kannel_sender_password = "tigotchad"
    else
      kannel_sender_username = "vodacomcongo"
      kannel_sender_password = "vodacomcongo"
    end
    @message = CGI::escape(message)
    @destination = phone_no.strip()
    url = URI.parse("http://#{KANNEL_HOST}:#{KANNEL_SEND_SMS_PORT}")
    @resp_url = CGI::escape("http://#{EZGATE_HOST}/service_manager/record_push?inbound_id=0&user_id=#{session[:user_id]}&service=push&dest=#{@destination}&sender=#{short_code.code}&content=#{@message}&smsc=%i&status=%d")
    @http = Net::HTTP.new(url.host, url.port)
    puts "***********************************************************************"
    puts "******************* Sending message via SMS Gateway *******************"
    puts "***********************************************************************";
    puts "To : #{@destination}"
    puts "Message content : \n#{message}";
    puts "Short code : #{short_code}"
    sms_gateway_response = @http.request_get("/cgi-bin/sendsms?username=#{kannel_sender_username}&password=#{kannel_sender_password}&from=#{short_code.code}&to=#{@destination}&text=#{@message}&dlr-mask=31&dlr-url=#{@resp_url}")
    puts "Response from SMS Gateway : ";
    puts sms_gateway_response.body
    return sms_gateway_response.code, sms_gateway_response.body
  end

  def toggle_completed
    update_page do |page|
      page[:value_received].visual_effect :highlight
    end
  end

  def show

  end

  def create

  end
end
