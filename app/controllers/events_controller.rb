class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :create, :search, :register_and_order]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :take_part, :create_comment]
  load_and_authorize_resource
  skip_authorize_resource :only => [:search, :register_and_order]

  # GET /events
  def index
    @event                  = Event.real.actual.order("RANDOM()").first
    @city                   = @event.try(:city)
    @cities_selection       = City.all.order(:name).map{ |c| [c.name, c.permalink] } << ["Любой город", nil]
    @event_types_selection  = EventType.all.order(:name).map{ |t| [t.name, t.permalink] } << ["Любой тип", nil]
  end

  def search
    @city = City.find_by_permalink(params[:city]) if params[:city]
    q = {
      city_permalink_eq: params[:city],
      event_type_permalink_eq: params[:type],
      days_name_eq: params[:date],
      name_cont: params[:name]
    }
    @all_events             = Event.real.actual.ransack(q).result.order('days.name').to_a.uniq
    @events                 = Kaminari.paginate_array(@all_events).page(params[:page])
    @cities_selection       = City.all.order(:name).map{ |c| [c.name, c.permalink] } << ["Любой город", nil]
    @event_types_selection  = EventType.order(:name).all.map{ |t| [t.name, t.permalink] } << ["Любой тип", nil]
  end

  # GET /events/1
  def show
    @city = @event.city
    @images = @event.images.where.not(id: @event.images.first)
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @event = current_user.events.new(event_params)

    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render :new
    end
  end

  def dates
    if params[:day] and params[:day][:date].present?
      @dates = Day.parse(params[:day][:date])
      if @dates.kind_of? (Array)
        @dates.map!{ |d|
          I18n.localize(Date.parse(d), format: "%d %b")
        }
        @dates = @dates.join(", ")
      else
        @dates = I18n.localize(Date.parse(@dates), format: "%d %b")
      end
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

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    redirect_to events_url, notice: 'Event was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find_by_permalink(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def event_params
      #all = params[:event][:event_description_attributes][:content].keys
      params.require(:event).permit(:name, :event_type, :city, :date, :content,
                                    :teaser, :min_price, :max_price,
                                    images_attributes: [:id, :_destroy, :attachment], comment: [:comment])
    end

    def user_params
      params.require(:user).permit(:name, :phone, :email, :password, :sex)
    end
end
