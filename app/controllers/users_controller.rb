class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /users
  def index
    @users = User.page(params[:page])
  end

  # GET /users/1
  def show
    @events = @user.events.page(params[:events_page])
    @ordered_events = Event.where(id: @user.orders.pluck(:event_id)).page(params[:ordered_events_page])
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Профиль успешно обновлен.'
    else
      render :edit
    end
  end

  def orders
    @clients = current_user.clients.page(params[:page])
  end

  def register
    password = Devise.friendly_token.first(8)
    @user = User.new(email: params[:user][:email], password: password)
    if @user.save
      sign_in @user
      redirect_to edit_user_path(@user), flash: { notice: "Вы успешно зарегистрировались. Ваш пароль: #{password}. Запишите его, а лучше поменяйте его прямо сейчас." }
    else
      render :new
    end

  end

  def new
    @user = User.new
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      to_permit = [:name, :phone, :email, :password, :sex, :avatar, :birthdate, :about]
      to_permit.delete(:password) unless params[:user][:password].present?
      params.require(:user).permit(*to_permit)
    end

end
