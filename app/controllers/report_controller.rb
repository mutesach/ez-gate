require 'csv'
class ReportController < ApplicationController
	before_filter :authorize
	before_filter :role_moderator
	def index
		
	end
	
	def convert_date(obj)
	 	return Date.new(obj['(1i)'].to_i,obj['(2i)'].to_i,obj['(3i)'].to_i)
	end
	 
	def custom_request_outbound
		act = "custom_report"
		condition1 = ""
  	condition1 = "outbound_messages.user_id = #{session[:user_id]}" unless session[:user_type] == "SA"
  	condition2 = "" 	

  	if params[:outbound][:rep_service] == ""
  		condition1 = condition1
  		service = ""
  		service_f = "all"
  	else
  		service = "inbound_messages.service_id = '#{params[:outbound][:rep_service]}'"
  		service_a = Service.find(:first, :conditions => "id = '#{params[:outbound][:rep_service]}'")
  		service_f = service_a.name  		
  		if condition1 != ""
  			condition1 = condition1 + " and " + service			
  		else
  			condition1 = service
  		end
  	end
  	  	
  	if self.convert_date(params[:out_rep_date]) == Date.today
  		date = ""
  		date_f = "all" 		
  	else
  		params[:id] = self.convert_date(params[:out_rep_date])
  		date1 = "date(outbound_messages.created_at) = '#{params[:id]}'"
  		date_f = params[:id]
  		if condition1 != ""
  			condition1 = condition1 + " and " + date1
  		else
  			condition1 = date1
  		end
  	end
  	
  	if params[:outbound][:rep_month] == ""
  		condition1 = condition1
  		month = ""
  		month_f = "all"
  	else
  		month1 = "month(outbound_messages.created_at) = '#{params[:outbound][:rep_month]}'"
  		month_f = inboundMessage::MONTHS[params[:outbound][:rep_month].to_i - 1][0]
  		if condition1 != ""
  			condition1 = condition1 + " and " + month1
  		else
  			condition1 = month1
  		end
  	end
  	
  	if params[:outbound][:rep_year] == ""
  		condition1 = condition1
  		year = ""
  		year_f = "all"
  	else
  		year1 = "year(outbound_messages.created_at) = '#{params[:outbound][:rep_year]}'"
  		year_f = params[:outbound][:rep_year]
  		if condition1 != ""
  			condition1 = condition1 + " and " + year1
  		else
  			condition1 = year1
  		end
  	end
  	
  	if params[:outbound][:rep_operator] == ""
  		condition1 = condition1
  		operator_f = "all"
  	else
  		operator = "inbound_messages.smsc = '#{params[:outbound][:rep_operator]}'"
  		operator_f = params[:outbound][:rep_operator]
  		condition2 = condition2 + " and " + operator
  		if condition1 != ""
  			condition1 = condition1 + " and " + operator
  		else
  			condition1 = operator
  		end
  		if condition2 != ""
  			condition2 = condition2 + " and " + operator
  		else
  			condition2 = operator
  		end
  	end

		outbound = OutboundMessage.count(:all,
      :joins => "left join inbound_messages on outbound_messages.inbound_id=inbound_messages.id
			left join services on inbound_messages.service_id=services.id left join short_codes on short_codes.code=outbound_messages.sender",
      :conditions => condition1)
  	if outbound > 0
			result1 = OutboundMessage.find(:all,
        :joins => "left join inbound_messages on outbound_messages.inbound_id=inbound_messages.id
			left join services on inbound_messages.service_id=services.id left join short_codes on short_codes.code=outbound_messages.sender",
        :select => "inbound_messages.smsc, outbound_messages.user_id, services.name, outbound_messages.sender,
			outbound_messages.destination, inbound_messages.content, outbound_messages.status_message, short_codes.sms_cost,
			outbound_messages.created_at", :conditions => condition1)
			
			result2 = OutboundMessage.find(:all,
        :joins => "left join inbound_messages on outbound_messages.inbound_id=inbound_messages.id
			left join services on inbound_messages.service_id=services.id left join short_codes on short_codes.code=outbound_messages.sender",
        :select => "count(*) as sum_count , short_codes.sms_cost as sum_cost, short_codes.smsc, short_codes.code, short_codes.sms_cost",
        :conditions => condition1, :group => "outbound_messages.sender")
		  @outfile = "ezGate_outbound_messages_" + Time.now.strftime("%m-%d-%Y") + ".csv"
			total_price = 0
			csv_data = CSV.generate do |csv|
				
				csv << ["outbound MESSAGES"]
				csv << [""]
				csv << ["Selection criteria"]
			  csv << [""]
			  csv << ["Date", date_f]
			  csv << ["Month", month_f]
			  csv << ["Year", year_f]
			  csv << ["Service", service_f]
			  csv << ["Operator", operator_f]
				csv << ["Record(s) found", outbound]
				csv << [""]
			 	csv << ["SMSC", "Destination #", "Short Code", "Service", "Content", "Date/Time", "Status", "SMS cost"]		  
			  
			  result1.each do |sms|
			  	total_price = total_price + sms.sms_cost.to_i unless sms.sms_cost.nil?
			  	csv << [ sms.smsc, sms.destination, sms.sender, sms.name, sms.content, sms.created_at, sms.status_message, sms.sms_cost]	
				end
				csv << [""]
			  csv << ["SMSC", "Code", "Unit cost", "Total message(s)", "Total cost"]
				result2.each do |code|					
			  	csv << [ code.smsc, code.code, code.sms_cost, code.sum_count, code.sum_count.to_i * code.sum_cost.to_i]
				end
				csv << [""]
			  csv << ["Total cost", total_price]
			  csv << [""]
				
				

			end
	    
	   	send_data csv_data,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{@outfile}"
		else
			flash[:notice] = "#{outbound} record(s) found"
		  redirect_to :controller => "report", :action => "index"	
	  end			
  end
  
  
	def custom_request_inbound
		act = "custom_report"
		condition1 = ""
  	condition1 = "inbound_messages.user_id = #{session[:user_id]}" unless session[:user_type] == "SA"
  	condition2 = "" 	

  	if params[:inbound][:rep_service] == ""
  		condition1 = condition1
  		service = ""
  		service_f = "all"
  	else
  		service = "service_id = '#{params[:inbound][:rep_service]}'"
  		service_a = Service.find(:first, :conditions => "id = '#{params[:inbound][:rep_service]}'")
  		service_f = service_a.name  		
  		if condition1 != ""
  			condition1 = condition1 + " and " + service			
  		else
  			condition1 = service
  		end
  	end
  	  	
  	if self.convert_date(params[:in_rep_date]) == Date.today
  		date = ""
  		date_f = "all" 		
  	else
  		params[:id] = self.convert_date(params[:in_rep_date])
  		date1 = "date(inbound_messages.created_at) = '#{params[:id]}'"
  		date_f = params[:id]
  		if condition1 != ""
  			condition1 = condition1 + " and " + date1
  		else
  			condition1 = date1
  		end
  	end
  	
  	if params[:inbound][:rep_month] == ""
  		condition1 = condition1
  		month = ""
  		month_f = "all"
  	else
  		month1 = "month(inbound_messages.created_at) = '#{params[:inbound][:rep_month]}'"
  		month_f = inboundMessage::MONTHS[params[:inbound][:rep_month].to_i - 1][0]
  		if condition1 != ""
  			condition1 = condition1 + " and " + month1
  		else
  			condition1 = month1
  		end
  	end
  	
  	if params[:inbound][:rep_year] == ""
  		condition1 = condition1
  		year = ""
  		year_f = "all"
  	else
  		year1 = "year(inbound_messages.created_at) = '#{params[:inbound][:rep_year]}'"
  		year_f = params[:inbound][:rep_year]
  		if condition1 != ""
  			condition1 = condition1 + " and " + year1
  		else
  			condition1 = year1
  		end
  	end
  	

  	if params[:inbound][:rep_operator] == ""

      if params[:inbound][:rep_service] == ""

        condition1 = condition1
        operator_f = "all"
      else

        operator = "inbound_messages.smsc = '#{params[:inbound][:rep_operator]}'"
        operator_f = params[:inbound][:rep_operator]

        service = "inbound_messages.service = '#{params[:inbound][:rep_service]}'"
        service_f = params[:inbound][:rep_service]
        condition2 = condition2 + " and " + service
        if condition1 != ""
          condition1 = condition1 + " and " + service
        else
          condition1 = service
        end
        if condition2 != ""
          condition2 = condition2 + " and " + service
        else
          condition2 = service
        end
      end
  	
      if params[:inbound][:rep_user] == ""
        condition1 = condition1
        operator_f = "all"
      else
        user = "inbound_messages.user_id = '#{params[:inbound][:rep_user]}'"
        user_f = params[:inbound][:rep_user]
        condition2 = condition2 + " and " + user
        if condition1 != ""
          condition1 = condition1 + " and " + user
        else
          condition1 = user
        end
        if condition2 != ""
          condition2 = condition2 + " and " + user
        else
          condition2 = user
        end
      end
  	
      if params[:inbound][:rep_operator] == ""
        condition1 = condition1
        operator_f = "all"
      else
        operator = "inbound_messages.smsc = '#{params[:inbound][:rep_operator]}'"
        operator_f = params[:inbound][:rep_operator]

        condition2 = condition2 + " and " + operator
        if condition1 != ""
          condition1 = condition1 + " and " + operator
        else
          condition1 = operator
        end
        if condition2 != ""
          condition2 = condition2 + " and " + operator
        else
          condition2 = operator
        end
      end

      inbound = InboundMessage.count(:all,
        :joins => "left join services on inbound_messages.service_id=services.id left join short_codes on short_codes.code=inbound_messages.destination",
        :conditions => condition1)
      if inbound > 0
        result1 = InboundMessage.find(:all,
          :joins => "left join services on inbound_messages.service_id=services.id left join short_codes on short_codes.code=inbound_messages.destination",
          :select => "inbound_messages.smsc, inbound_messages.user_id, services.name, inbound_messages.sender,
			inbound_messages.destination, inbound_messages.content, inbound_messages.service_status, short_codes.sms_cost,
			inbound_messages.created_at", :conditions => condition1)
			
        result2 = InboundMessage.find(:all,
          :joins => "left join services on inbound_messages.service_id=services.id left join short_codes on short_codes.code=inbound_messages.destination",
          :select => "count(*) as sum_count , short_codes.sms_cost as sum_cost, short_codes.smsc, short_codes.code, short_codes.sms_cost",
          :conditions => condition1, :group => "inbound_messages.destination")
        @outfile = "ezGate_inbound_messages_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        total_price = 0
        csv_data = CSV.generate do |csv|
          csv << ["inbound MESSAGES"]
          csv << [""]
          csv << ["Selection criteria"]
          csv << [""]
          csv << ["Date", date_f]
          csv << ["Month", month_f]
          csv << ["Year", year_f]
          csv << ["Service", service_f]
          csv << ["Operator", operator_f]
          csv << ["Record(s) found", inbound]
          csv << [""]
          csv << ["SMSC", "Sender #", "Short Code", "Service", "Content", "Date/Time", "Service Status", "SMS cost"]
			  
          result1.each do |sms|
            total_price = total_price + sms.sms_cost.to_i unless sms.sms_cost.nil?
            csv << [ sms.smsc, sms.sender, sms.destination, sms.name, sms.content, sms.created_at, sms.service_status, sms.sms_cost]
          end
          csv << [""]
          csv << ["SMSC", "Code", "Unit cost", "Total message(s)", "Total cost"]
          result2.each do |code|
            csv << [ code.smsc, code.code, code.sms_cost, code.sum_count, code.sum_count.to_i * code.sum_cost.to_i]
          end
          csv << [""]
          csv << ["Total cost", total_price]
          csv << [""]
        end
    
        send_data csv_data,
          :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=#{@outfile}"
      else
        flash[:notice] = "#{inbound} record(s) found"
        redirect_to :controller => "report", :action => "index"
      end
    end
  end
  


  def summary


    params[:date_from] = self.convert_date(params[:date_from])
		params[:date_to] = self.convert_date(params[:date_to])

    case session[:user_type]
    when "SA" then
      conditions = ""
    when "Administrator" then
      conditions = ""
    when "Service-Aggregator" then
      conditions = "user_id = '#{session[:user_id]}' and "
    when "Bulk-push" then
      conditions = "user_id = '#{session[:user_id]}' and "
    when "Moderator" then
      @user_mod = UserModService.where("user_mod_id=#{session[:user_id]} and ")
      sel = ''
      conditions = ''
      @user_mod.each do |i|
			 	sel = sel + "'" + i.service_id.to_s + "'" + ","
      end
      sel = sel.slice(0, sel.length()-1)
      conditions = "id in('#{sel}')" unless @user_mod.nil?
      conditions = "id in('')" unless sel != nil
		end

		#inbound = InboundMessage.where("#{conditions}date(inbound_messages.created_at) >= '#{params[:date_from]})' and date(inbound_messages.created_at) <= '#{params[:date_to]}'").joins("left join short_codes on short_codes.code=inbound_messages.destination").count
    #outbound = OutboundMessage.where("#{conditions}date(outbound_messages.created_at) >= '#{params[:date_from]})' and date(outbound_messages.created_at) <= '#{params[:date_to]}'").joins("left join short_codes on short_codes.code=outbound_messages.destination").count

    inbound = InboundMessage.joins("left join services on inbound_messages.service_id=services.id left join short_codes on short_codes.code=inbound_messages.destination").select("inbound_messages.user_id,inbound_messages.smsc, services.name, inbound_messages.sender,inbound_messages.destination, inbound_messages.content, inbound_messages.service_status, short_codes.sms_cost,inbound_messages.created_at").where("#{conditions}date(inbound_messages.created_at) >= '#{params[:date_from]})' and date(inbound_messages.created_at) <= '#{params[:date_to]}'")
    outbound = OutboundMessage.joins("left join services on outbound_messages.service=services.name join short_codes on short_codes.code=outbound_messages.sender").select("outbound_messages.user_id,outbound_messages.service, outbound_messages.sender,outbound_messages.destination, outbound_messages.content, outbound_messages.status, short_codes.sms_cost,outbound_messages.created_at").where("#{conditions}date(outbound_messages.created_at) >= '#{params[:date_from]})' and date(outbound_messages.created_at) <= '#{params[:date_to]}'")

    short_codes = ShortCode.where("code != 'all'")

    @outfile = "ezGate_summary_report_" + Time.now.strftime("%m-%d-%Y") + ".csv"

    csv_data = CSV.generate do |csv|
      csv << ["Summary Report"]
      csv << [""]
      csv << ["Date", "From : #{params[:date_from]} to #{params[:date_to]}"]
      csv << ["Total Inbound", inbound.count]
      csv << ["Total Outbound", outbound.count]
      csv << [""]
      
      short_codes.each do |code|
        csv << [code.smsc]
        csv << ["", "Short Code", code.code]
        csv << ["", "Unit price", code.sms_cost]
        csv << ["", "Inbound", inbound.where("destination='#{code.code}'").count]
        csv << ["", "Outbound", outbound.where("sender='#{code.code}'").count]
        users = User.order("name ASC")
        users.each do |user|
          csv << ["","","","",user.name]
          services = Service.where("#{conditions}id != 1")
          services.each do |serv|
            csv << ["","","","", "", serv.name, "in", inbound.where("destination='#{code.code}' and service_id=#{serv.id} and inbound_messages.user_id=#{user.id}").count, "out",outbound.where("sender='#{code.code}' and service='#{serv.name}' and outbound_messages.user_id=#{user.id}").count] unless serv.user_id != user.id
          end
        end
      end
      csv << [""]
      csv << [""]
      csv << ["#{inbound.where("service_id=1").group("smsc").first} [unknown services]"]
      csv << ["","Short Code",inbound.where("service_id=1").group("inbound_messages.destination").first]
      csv << ["", "Inbound", inbound.where("service_id=1").count]
    end

    send_data csv_data,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@outfile}"
  end
end
