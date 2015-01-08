class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def vkontakte
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in(:user, @user)
    redirect_to root_path, flash: { notice: "Successfully logged on via Vkontakte" }
  end
end