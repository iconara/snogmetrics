class SnogsController < ApplicationController

  def create
    km.identify(params[:snog][:who])
    km.record('want_to_snog', :whom => params[:snog][:whom])
    redirect_to thank_you_snogs_path
  end
  
end