class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :create, :search, :register_and_order, :new]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :take_part, :create_comment, :destroy_comment]
  load_and_authorize_resource
  skip_authorize_resource :only => [:search, :register_and_order, :new]

  # GET /events
  def index
    descr                   = City.all.map{ |c| I18n.t("cities.#{c.permalink}.gen") }.join(", ")
    @event                  = Event.real.actual.order("RANDOM()").first
    @city                   = @event.try(:city)
    @cities_selection       = City.all.order(:name).map{ |c| [c.name, c.permalink] } << ["Все города", nil]
    @event_types_selection  = EventType.all.order(:name).map{ |t| [t.name, t.permalink] } << ["Все события", nil]
    @seo_description        = "Теренкур. Мы знаем, куда пойти #{descr}"
    @seo_keywords           = EventType.all.map{ |e| e.name }.join(', ') << " " << descr
  end

  def search
    Event.connection.execute("select setseed(0.5)")
    descr                   = City.all.map{ |c| I18n.t("cities.#{c.permalink}.gen") }.join(", ")
    @city = City.find_by_permalink(params[:city]) if params[:city]
    q = {
      city_permalink_eq: params[:city],
      event_type_permalink_eq: params[:type],
      days_name_eq: params[:date],
      name_cont: params[:name]
    }
    @all_events             = Event.real.actual.ransack(q).result.order('RANDOM()').to_a.uniq
    @events                 = Kaminari.paginate_array(@all_events).page(params[:page])
    @cities_selection       = City.all.order(:name).map{ |c| [c.name, c.permalink] } << ["Любой город", nil]
    @event_types_selection  = EventType.order(:name).all.map{ |t| [t.name, t.permalink] } << ["Любой тип", nil]
    @seo_description        = "Теренкур. Мы знаем, куда пойти #{descr}"
    @seo_keywords           = EventType.all.map{ |e| e.name }.join(', ') << " " << descr
  end

  # GET /events/1
  def show
    @city = @event.city
    @images = @event.images.where.not(id: @event.images.first)
    @seo_description = @event.text_teaser
    @seo_keywords = @event.event_type.keywords.split("\n").join(',')
  end

  # GET /events/new
  def new
    redirect_to new_user_path unless current_user
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @event = current_user.events.new(event_params)

    if @event.save
      redirect_to @event, notice: 'Событие успешно создано.'
    else
      render :new
    end
  end

  def take_part
    if current_user.orders.create(event: @event)
      redirect_to event_path(@event), flash: { notice: "Вы успешно подали заявку на участие в #{@event.name}" }
    else
      redirect_to event_path(@event), flash: { error: "При оформлении заявки на #{@event.name} произошла ошибка" }
    end
  end

  def register_and_order
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      @event = Event.find(params[:event_id])
    end
  end

  def create_comment
    comment = @event.comments.new(event_params[:comment])
    comment.user = current_user
    if comment.save
      redirect_to :back, flash: { notice: "Ваш комменатрий добавлен." }
    else
      redirect_to :back, flash: { error: "Произошла ошибка. Комментарий не сохранен." }
    end
  end

  def destroy_comment
    comment = @event.comments.find(params[:comment_id])
    authorize! :destroy, comment

    redirect_to :back, notice: 'Комментарий успешно удален' if comment.destroy
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Событие успешно обновлено.'
    else
      render :edit
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    redirect_to events_url, notice: 'Событие успешно удалено.'
  end

  def parse_vk
    City.get_all_vk
    redirect_to tests_path, notice: "ВКонтакте добавлен в обработку."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find_by_permalink(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def event_params
      #all = params[:event][:event_description_attributes][:content].keys
      to_permit =
      [
        :name, :event_type, :city, :date, :content, :teaser, :min_price,
        :max_price,
        images_attributes: [:id, :_destroy, :attachment],
        comment: [:comment]
      ]
      to_permit << :announce if current_user.admin?
      params.require(:event).permit(*to_permit)
    end

    def user_params
      to_permit = [:name, :phone, :email, :password, :sex]
      params.require(:user).permit(*to_permit)
    end
end
