class RecurringEventsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :author_actions, only: %i[update destroy]

  def index
    @events = current_user.events.where('events.end > ?', params[:start]).where('events.start < ?', params[:end]).where.not(frequency: nil)
    respond_to do |format|
      format.json { render json: event_serialize(@events).target! }
    end
  end

  def all
    @events = Event.where('events.end > ?', params[:start]).where('events.start < ?', params[:end]).where.not(frequency: nil).includes(:user)
    respond_to do |format|
      format.json { render json: event_serialize(@events).target! }
    end
  end

  def create
    @event = current_user.events.new(recurring_event_params)
    if @event.save
      success_response(@event)
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if event.update(recurring_event_params)
      success_response(event, 'updated')
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if event.destroy
      success_response(event, 'deleted')
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def event
    @event ||= params[:id] ? Event.find(params[:id]) : current_user.events.new
  end

  private

  helper_method :event

  def author_actions
    unless current_user.author?(event)
      redirect_to root_path, notice: "You don't have rights to perform this action"
    end
  end

  def success_response(event, state = nil)
    render json: {
      state: state,
      id: event.id,
      title: event.title,
      source: 'recurring_event',
      editable: false,
      recurring: true,
      color: '#ff00bf',
      rrule: {
        freq: event.frequency,
        dtstart: event.start,
        until: event.end
      }
    }
  end

  def event_serialize(events)
    Jbuilder.new do |obj|
      obj.array!(events) do |event|
        obj.id event.id
        obj.editable false
        obj.title event.title
        obj.recurring true
        obj.color '#ff00bf' if current_user.author?(event)
        obj.rrule do
          obj.freq event.frequency
          obj.dtstart event.start
          obj.until event.end
        end
      end
    end
  end

  def recurring_event_params
    params.require(:recurring_event).permit(:title, :start, :end, :frequency)
  end
end
