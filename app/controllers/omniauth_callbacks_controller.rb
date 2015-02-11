class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def vkontakte
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in(:user, @user)
    message = "Здравствуйте, #{@user.name.split(' ').first}, Вы успешно зашли на сайте через ВКонтакте."
    message << " Пожалуйста, заполните свой телефон в профиле, что бы организаторы могли с Вами связаться." unless @user.phone.present?
    redirect_to root_path, flash: { notice: message }
  end
end