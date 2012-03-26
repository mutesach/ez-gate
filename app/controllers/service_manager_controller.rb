require 'net/http'
class ServiceManagerController < ApplicationController
  def request_handler
  	t1 = Thread.new() {
	  	if request.env["HTTP_USER_AGENT"] == "Kannel/1.4.3"
        if params[:smsc] != nil or params[:content] != nil or params[:sender] != nil or params[:keyword] != nil
          @service  = Service.find(:first, :conditions => "keyword = '#{params[:keyword]}' or aliases like '%#{params[:keyword]}%'",
            :joins => "left join short_codes on short_codes.code='#{params[:destination]}'",
            :select => "services.id as service_id, services.user_id, services.status, services.content_type, services.reply, services.reply_content, services.web_service_id,services.user_short_code_id, services.name, services.keyword, services.aliases, short_codes.id, short_codes.code, short_codes.smsc")
          #@code = ShortCode.find(:first, :conditions => "user_short_codes.user_id = #{@service.user_id} and code != 'All'",
					#	:joins => "left join user_short_codes on user_short_codes.short_code_id=#{@service.user_short_code_id}",
					#	:select => "user_short_codes.user_id, short_codes.code, short_codes.id, short_codes.smsc") unless @service.nil?

          if @service != nil and @service.code == params[:destination]
		      	req = InboundMessage.create(:smsc => @service.smsc,
              :user_id => @service.user_id,
              :service_id => @service.service_id,
              :sender => params[:sender],
              :destination => params[:destination],
              :content => params[:content],
              :created_at => Time.now(),
              :service_status => "pending")
		      	short_code = params[:destination]
		      	
		      	@result = "Incoming message successfuly recorded
		      						| content : #{params[:content]}"
		      	if @service.status == true
              short = ShortCode.find_by_id(@service.user_short_code_id)
			      	case @service.content_type
              when "Static" then
                if @service.reply == true
                  user_id = @service.user_id
                  service = @service.keyword
                  if @service.reply_content != nil
                    req.update_attribute(:service_status, "success")
                    self.send_sms(req, user_id, params[:sender],
			      					short.code, @service, @service.reply_content)
                  else
                    content = "Service content not available for the moment. Contact service provider.\n"
                    req.update_attribute(:service_status, "failed")
                    req.update_attribute(:status_message, "content not available")
                    self.send_sms(req, user_id, params[:sender], short.code,
			      					@service, content)
                  end
                else
                  req.update_attribute(:service_status, "success")
                  if @service.name == "SMS Alert"
                    self.get_sms_alerts(params[:smsc], params[:content], params[:sender])
                  end
                end
              when "Dynamic" then
                @web_service = WebService.find(:first,
			      			:conditions => "id = '#{@service.web_service_id}'")
                user_id = @service.user_id
                service = @service.keyword
                if @web_service != nil
                  if @web_service.default_param != true
                    no_of_required_params = 0
                    no_of_sent_params = 0
                    no_of_required_params = no_of_required_params + 1 unless @web_service.param1 == ""
                    no_of_required_params = no_of_required_params + 1 unless @web_service.param2 == ""
                    no_of_required_params = no_of_required_params + 1 unless @web_service.param3 == ""
                    no_of_required_params = no_of_required_params + 1 unless @web_service.param4 == ""
                    no_of_required_params = no_of_required_params + 1 unless @web_service.param5 == ""
                    no_of_required_params = no_of_required_params + 1 unless @web_service.param6 == ""
                    no_of_required_params = no_of_required_params + 1 unless @web_service.param7 == ""
                    no_of_required_params = no_of_required_params + 1 unless @web_service.param8 == ""
                    no_of_required_params = no_of_required_params + 1 unless @web_service.param9 == ""
                    no_of_required_params = no_of_required_params + 1 unless @web_service.param10 == ""

                    no_of_sent_params = params[:content].split(/ /).length() - 1
                    sent_params = params[:content].split(/ /)
                    if no_of_required_params == no_of_sent_params
                      service_params = ""
                      service_params = @web_service.param1.strip() + "=" + sent_params[1] unless @web_service.param1 == ""
                      service_params = service_params + "&" + @web_service.param2.strip() + "=" + CGI::escape(sent_params[2]) unless @web_service.param2 == ""
                      service_params = service_params + "&" + @web_service.param3.strip() + "=" + CGI::escape(sent_params[3]) unless @web_service.param3 == ""
                      service_params = service_params + "&" + @web_service.param4.strip() + "=" + CGI::escape(sent_params[4]) unless @web_service.param4 == ""
                      service_params = service_params + "&" + @web_service.param5.strip() + "=" + CGI::escape(sent_params[5]) unless @web_service.param5 == ""
                      service_params = service_params + "&" + @web_service.param6.strip() + "=" + CGI::escape(sent_params[6]) unless @web_service.param6 == ""
                      service_params = service_params + "&" + @web_service.param7.strip() + "=" + CGI::escape(sent_params[7]) unless @web_service.param7 == ""
                      service_params = service_params + "&" + @web_service.param8.strip() + "=" + CGI::escape(sent_params[8]) unless @web_service.param8 == ""
                      service_params = service_params + "&" + @web_service.param9.strip() + "=" + CGI::escape(sent_params[9]) unless @web_service.param9 == ""
                      service_params = service_params + "&" + @web_service.param10.strip() + "=" + CGI::escape(sent_params[10]) unless @web_service.param10 == ""
                      content = self.web_service_request(req, params[:sender], service_params, @web_service)
                      self.send_sms(req, user_id, params[:sender], short_code, @service, content)
                    else
                      service_params = ""
                      service_params = service_params + @web_service.param1.strip() unless @web_service.param1 == ""
                      service_params = service_params + "," + @web_service.param2.strip() unless @web_service.param2 == ""
                      service_params = service_params + "," + @web_service.param3.strip() unless @web_service.param3 == ""
                      service_params = service_params + "," + @web_service.param4.strip() unless @web_service.param4 == ""
                      service_params = service_params + "," + @web_service.param5.strip() unless @web_service.param5 == ""
                      service_params = service_params + "," + @web_service.param6.strip() unless @web_service.param6 == ""
                      service_params = service_params + "," + @web_service.param7.strip() unless @web_service.param7 == ""
                      service_params = service_params + "," + @web_service.param8.strip() unless @web_service.param8 == ""
                      service_params = service_params + "," + @web_service.param9.strip() unless @web_service.param9 == ""
                      service_params = service_params + "," + @web_service.param10.strip() unless @web_service.param10 == ""
                      content = "Invalid parameters\n"
                      req.update_attribute(:service_status, "failed")
                      req.update_attribute(:status_message, content)
                      self.send_sms(req, user_id, params[:sender], short_code, @service, content)
                    end
                  else
                    service_params = ""
                    service_params = @web_service.param1.strip()  unless @web_service.param1 == ""
                    service_params = service_params + "&" + @web_service.param2.strip() unless @web_service.param2 == ""
                    service_params = service_params + "&" + @web_service.param3.strip() unless @web_service.param3 == ""
                    service_params = service_params + "&" + @web_service.param4.strip() unless @web_service.param4 == ""
                    service_params = service_params + "&" + @web_service.param5.strip() unless @web_service.param5 == ""
                    service_params = service_params + "&" + @web_service.param6.strip() unless @web_service.param6 == ""
                    service_params = service_params + "&" + @web_service.param7.strip() unless @web_service.param7 == ""
                    service_params = service_params + "&" + @web_service.param8.strip() unless @web_service.param8 == ""
                    service_params = service_params + "&" + @web_service.param9.strip() unless @web_service.param9 == ""
                    service_params = service_params + "&" + @web_service.param10.strip() unless @web_service.param10 == ""
                    content = self.web_service_request(req, params[:sender], service_params, @web_service)
                    self.send_sms(req, user_id, params[:sender], short_code, @service, content)
                  end
                else
                  content = "Service not available for the moment. Contact service provider.\n"
                  req.update_attribute(:service_status, "failed")
                  req.update_attribute(:status_message, "service not available")
                  self.send_sms(req, user_id, params[:sender], short_code, @service, content)
                end
			   			end
		   			else
		   				req.update_attribute(:service_status, "Service not active")
		   			end

					else
            case params[:smsc]
            when "vodacomcongo" then
              smsc = "Vodacom DRC"
            when "tigocongo" then
              smsc = "Tigo DRC"
            when "tigotchad" then
              smsc = "Tigo Tchad"
            else
              smsc = params[:smsc]
            end
						req = InboundMessage.create(:smsc => smsc,
              :user_id => 1,
              :service_id => 1,
              :destination => params[:destination],
              :sender => params[:sender],
              :content => params[:content],
              :service_status => "failed",
              :status_message => "service not available",
              :created_at => Time.now())
		      	
						@result = "Unknown service | content : #{params[:content]}"
					end
				else
					@result = "Missing required parameters | content : #{params[:content]}"
				end
			else
				@result = "Permission denied : Invalid USER_AGENT : contact sys. admin."
			end
		}
		t1.join
	end

  def send_sms(inbound, user_id, destination, short_code, service, message)
  	@user = User.find(user_id)
    short_code = ShortCode.find(service.user_short_code_id)
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
  	if @user.sms_stock > 0 or @user.sms_limit == false
  		@user.update_attribute(:sms_stock, @user.sms_stock - 1) unless @user.sms_limit == false
	    @message = CGI::escape(message)
	    @destination = destination.strip()
	    url = URI.parse("http://#{KANNEL_HOST}:#{KANNEL_SEND_SMS_PORT}")
	    inbound_id = inbound.id
	    @resp_url = CGI::escape("http://#{EZGATE_HOST}/service_manager/record_push?inbound_id=#{inbound_id}&user_id=#{user_id}&service=#{service.keyword}&dest=#{destination}&sender=#{short_code.code}&content=#{@message}&smsc=%i&status=%d")
	    @http = Net::HTTP.new(url.host, url.port)
	    puts "*******************************************************************"
	    puts "******************* Sending SMS via SMS Gateway *******************"
	    puts "*******************************************************************";
	    puts "To : #{destination}"
	    puts "Message content : \n#{message}";
	    sms_gateway_response = @http.request_get("/cgi-bin/sendsms?username=#{kannel_sender_username}&password=#{kannel_sender_password}&from=#{short_code.code}&to=#{@destination}&text=#{@message}&dlr-mask=31&dlr-url=#{@resp_url}")
	    puts "Response from SMS Gateway : ";
	    puts sms_gateway_response.body
    else
    	inbound.update_attribute(:service_status, "failed")
    	OutboundMessage.create(:inbound_id => inbound.id,
				:user_id => user_id,
				:service => service.keyword,
				:sender => short_code,
				:destination => destination,
				:content => message,
				:status => "failed",
				:status_message => "sms stock not available")
    end
  end

	def record_push
		case params[:status]
    when "0" then @status = "Accepted for delivery"
    when "1" then @status = "delivered"
    when "2" then @status = "failed"
    when "4" then @status = "buffered"
    when "8" then @status = "submitted"
    when "16" then @status = "rejected"
		end
		
    OutboundMessage.create(:inbound_id => params[:inbound_id],
      :user_id => params[:user_id], :service => params[:service],
      :sender => params[:sender], :destination => params[:dest],
      :content => params[:content], :status => @status,
      :status_message => @status)
  end

  def web_service_request(request, sender, service_params, web_service)
  	case web_service.web_service_type
    when "Get-URL" then
      begin
        url = URI.parse(web_service.web_service_uri)
        http = Net::HTTP.new(url.host, url.port)
        formatted_params = service_params
        puts service_params
        puts "*******************************************************************"
        puts "******************* Connecting to web service *********************"
        puts "*******************************************************************"
        puts ""
        puts "Web service : #{web_service.name}"
        puts "URI : #{web_service.web_service_uri}"
        puts "Parameters : #{service_params}"
        puts ""
        puts "#{web_service.web_service_uri}" + "?#{formatted_params}"
        webservice_response = http.request_get("#{url.path}?#{formatted_params}")
        puts "Response : #{webservice_response.code}"
        puts "#{web_service.web_service_uri}?#{service_params}"
        if webservice_response.code == "200"
          request.update_attribute(:service_status, "success")
        else
          request.update_attribute(:service_status, "failed")
        end
        result = webservice_response.body
      rescue Errno::ECONNREFUSED
        result = "The service is not available for the moment"
        request.update_attribute(:service_status, "failed")
        request.update_attribute(:status_message, result)
      rescue Timeout::Error
        result = "The request has timed out"
        request.update_attribute(:service_status, "failed")
        request.update_attribute(:status_message, result)
      rescue Errno::ECONNRESET
        result = "Server not available"
        request.update_attribute(:service_status, "failed")
        request.update_attribute(:status_message, result)
      rescue Errno::ENETUNREACH
        result = "Network unreachable"
        request.update_attribute(:service_status, "failed")
        request.update_attribute(:status_message, result)
      rescue SocketError
        result = "Name or service unknown"
        request.update_attribute(:service_status, "failed")
        request.update_attribute(:status_message, result)
      end
    when "POST-XML" then
      result = "POST-XML"
  	end
  	result
  end
 
  def service_test
  	@result = "web service content..."
    render :layout => false
  end

  def get_ringtone
    if !params[:id].nil?
      ringtone = Ringtone.where("keyword like '%#{params[:id]}%'").first
      if !ringtone.nil?
        if ringtone.status
          secret_key = RingtoneAccessKey.random_key(4)
          RingtoneAccessKey.create(:ringtone_id => ringtone.id,
            :key => secret_key,
            :expires_at => Time.now() + 1200,
            :req_status => "unused")
          @result = "Allez sur http://#{EZGATE_PUBLIC_HOST}/ringtones?id=#{ringtone.id} et telecharger votre sonnerie a l'aide du code secret suivant :\n#{secret_key}"
        else
          @result = "La sonnerie <#{ringtone.song_title}> n est plus disponible"
        end
      else
        @result = "Sonnerie non disponible"
      end
    else
      @result = "Code sonnerie invalid"
    end
    render :layout => false
  end
end
