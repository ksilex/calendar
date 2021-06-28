class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :author_actions, only: %i[update destroy]

  def index
    @events = current_user.events
    respond_to do |format|
      format.json { render json: event_serialize(@events).target! }
      format.html
    end
  end

  def all
    @events = Event.where(start: params[:start]..params[:end]).includes(:user)
    respond_to do |format|
      format.json { render json: event_serialize(@events).target! }
    end
  end

  def create
    @event = current_user.events.new(event_params)
    if @event.save
      success_response(@event)
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if event.update(event_params)
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
      start: event.start,
      end: event.end
    }
  end

  def event_serialize(events)
    Jbuilder.new do |obj|
      obj.array!(events) do |event|
        obj.id event.id
        obj.editable current_user.author?(event)
        obj.title event.title
        obj.start event.start
        obj.end event.end
      end
    end
  end

  def event_params
    params.require(:event).permit(:title, :start, :end)
  end

end
