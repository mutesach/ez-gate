class RingtonesController < ApplicationController
  def index
    if params[:id]
      @ringtone = Ringtone.find_by_id(params[:id])
      if @ringtone
        @message = "http://my-ezgate.com/yuejk"
      else
        @message = "Ringtone not available"
      end
    else
      @message = "Invalid ringtone code"
    end
    render :layout => false unless mobile_device?
  end

  def download_ringtone
    if !params[:ringtone_id].nil?
      @ringtone = Ringtone.find_by_id(params[:ringtone_id])
      if !params[:password].nil?
        #@ringtone = Ringtone.find_by_id(params[:ringtone_id])
        access = RingtoneAccessKey.validate(params[:ringtone_id], params[:password])
        if access
          if access.status
            if access.expires_at >= Time.now()
              send_file("#{@ringtone.f_path}/#{@ringtone.f_name}", :type => "audio/mpeg", :disposition => "attachment; filename=#{@ringtone.f_name.gsub(" ","-")}")
              access.update_attribute(:status, false)
              access.update_attribute(:used_at, Time.now())
            else
              flash[:notice] = "The secret key has expired"
            end
          else
            flash[:notice] = "The secret key has already been used"
          end
        else
          flash[:notice] = "The secret key is invalid"
        end
      else
        flash[:notice] = "The secret key is required"
      end
    else
      flash[:notice] = "Invalid ringtone"
    end
    render :layout => false unless mobile_device?
  end
end
