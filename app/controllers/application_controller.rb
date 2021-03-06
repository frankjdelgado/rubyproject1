class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	before_action :configure_permitted_parameters, if: :devise_controller?
   
   	before_filter :set_locale

   	def default_url_options(options={})
	  logger.debug "default_url_options is passed options: #{options.inspect}\n"
	  { locale: I18n.locale }
	end

	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :agency_id) }
		devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email, :password) }
		devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
	end

	def after_sign_in_path_for(resource)
		package_index_path
	end

	def after_sign_out_path_for(resource)
		root_path
	end

	def after_sign_up_path_for(resource)
		root_path
	end


	def get_shipping_cost(height,weight,depth,width,value)
		# Get last system rate added
		rate = Rate.active.first

		# Get params for formula
		packageRate = rate.package.to_f
		costRate 	= rate.cost.to_f
		height 		= height.to_f
		weight		= weight.to_f
		depth		= depth.to_f
		width		= width.to_f
		value		= value.to_f

		# calculate final cost
		shipping_cost = ((height*weight*depth*width)/packageRate) + (costRate*(value/100.0)) 

		# Round final cost
		shipping_cost = shipping_cost.round(2)

		return shipping_cost
	end

	private

 	def require_operator
		if current_user.is_member?
			flash[:error] = I18n.t('permissions')
			redirect_to '/'
		end
	end

	def require_admin
		if !current_user.is_admin?
			flash[:error] = I18n.t('permissions')
			redirect_to '/'
		end
	end

	def require_rates
		if Rate.active.empty?
			flash[:error] = I18n.t('cant_add_packages')
			redirect_to package_index_path
		end
	end

	def set_locale
	  I18n.locale = params[:locale] || I18n.default_locale
	end

end
