class HomeController < ApplicationController
  def index

  end

  def apps

  end

  def games

  end

  def ringtones
    @ringtones = Ringtone.all
  end
end
