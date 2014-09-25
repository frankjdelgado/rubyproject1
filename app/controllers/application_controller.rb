class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	before_action :configure_permitted_parameters, if: :devise_controller?
   
   before_action :set_locale
 
  	def set_locale
		I18n.locale = params[:locale] || I18n.locale
	end

	before_action :set_locale

	def set_locale
	  I18n.locale = params[:locale]
	end

	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :agency_id) }
		devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email, :password) }
	end

	def after_sign_in_path_for(resource)
		'/package'
	end

	def after_sign_out_path_for(resource)
		'/'
	end

	def after_sign_up_path_for(resource)
		'/'
	end

	private

 	def require_admin
		if current_user.role == 0
			flash[:error] = "You need permissions to access page"
			redirect_to '/'
		end
	end

end
