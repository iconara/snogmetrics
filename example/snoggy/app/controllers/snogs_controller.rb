class SnogsController < ApplicationController

  def create
    km_identify(params[:snog][:who])
    km_record('want_to_snog', :whom => params[:snog][:whom])
    redirect_to thank_you_snogs_path
  end
  
end