class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

	before_filter :set_locale 
	
  def set_locale 
    I18n.locale = params[:locale] || :en
  end 

  def default_url_options(options={}) 
    {:locale => I18n.locale.to_s}
  end

  USER_NAME, PASSWORD = "macbury", "password"

  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
    end
  end
end
