class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def sitemap
    DynamicSitemaps::Generator.new.generate
    render :file=>Rails.root.join('public', 'sitemaps', 'sitemap.xml'), :content_type => 'application/xml', layout: false
  end

  def robots
    render text: Conf['robots'], :content_type => 'text/plain', layout: false
  end

  def authenticate_admin_user!
    redirect_to root_path, flash: { error: t('errors.access.denied') } and return if user_signed_in? && !current_user.admin?
    authenticate_user!
  end

  def after_sign_in_path_for(resource)
    sign_in_urls = %w[http://localhost:3000/users/sign_in http://terenkur.com/users/sign_in http://home.vyskrebentsev.ru:3000/users/sign_in]
    if (request.referer.in?(sign_in_urls))
      env['omniauth.origin'] || request.env['omniauth.origin'] || stored_location_for(resource) || root_path #getting_started_path || root_path
    else
      request.referer || root_path
    end
  end

end
