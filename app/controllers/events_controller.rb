class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :new, :create, :search]
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  skip_authorize_resource :only => :search

  # GET /events
  def index
    @all_events = Event.all
    @events = @all_events.page(params[:page])
    @cities_selection = City.all.map{ |c| [c.name, c.permalink] }
    @event_types_selection = EventType.all.map{ |t| [t.name, t.permalink] }
  end

  def search
    q = {
      city_permalink_eq: params[:city],
      event_type_permalink_eq: params[:type]
    }
    @all_events = Event.ransack(q).result
    @events = @all_events.page(params[:page])
    @cities_selection = City.all.map{ |c| [c.name, c.permalink] }
    @event_types_selection = EventType.all.map{ |t| [t.name, t.permalink] }
    render :index
  end

  # GET /events/1
  def show
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
    user = current_user || User.auto_create(params[:event][:new_user_email])
    @event = user.events.new(event_params)

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
      all = params[:event][:event_description_attributes][:content].keys
      params.require(:event).permit(:name, :teaser, images_attributes: [:id, :attachment, :_destroy], event_description_attributes: [:id, :content])
    end
end
