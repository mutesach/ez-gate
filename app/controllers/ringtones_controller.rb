class RingtonesController < ApplicationController
  def index
    if params[:id]
      @ringtone = Ringtone.find_by_id(params[:id])
      if @ringtone
        @message = @ringtone.keyword
      else
        @message = "Sonnerie non disponible"
      end
    else
      @message = "Sonnerie invalide"
    end
  end

  def download_ringtone
    @ringtone = Ringtone.find_by_id(params[:ringtone][:id])
    key = RingtoneAccessKey.find_by_id(params[:access][:expiry])
    if key.expires_at >= Time.now()
      send_file("#{@ringtone.f_path}/#{@ringtone.f_name}", :type => "audio/mp3", :disposition => "attachment; filename=#{@ringtone.f_name}")
    else
      flash[:notice] = "Votre code secret n'est plus valide"
    end
  end

  def check_key
    if !params[:ringtone][:id].nil?
      @ringtone = Ringtone.find_by_id(params[:ringtone][:id])
      if !params[:password].nil?
        @access = RingtoneAccessKey.validate(params[:ringtone][:id], params[:password])
        if @access
          if @access.req_status == "unused"
            if @access.expires_at >= Time.now()
              @access.update_attribute(:req_status, "used")
              flash[:notice] = "Code secret valid, clickez sur Telecharger"
            else
              flash[:notice] = "Votre code secret n'est plus valide"
            end
          else
            flash[:notice] = "Votre secret n'est plus utilisable"
          end
        else
          flash[:notice] = "Votre code secret est invalide"
        end
      else
        flash[:notice] = "Veuillez saisir votre code secret"
      end
    else
      flash[:notice] = "Sonnerie invalide"
    end
  end
end