class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def index
    @events = current_user.events.where(start: params[:start]..params[:end])
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
    end
  end

  def update
    if event.update(event_params)
      success_response(event, true)
    end
  end

  def event
    @event ||= params[:id] ? Event.find(params[:id]) : current_user.events.new
  end

  private

  def success_response(event, updated = nil)
    render json: {
      updated: updated,
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
        obj.editable event.user_id == current_user.id ? true : false
        obj.title event.title
        obj.start event.start
        obj.end event.end
      end
    end
  end

  def event_params
    params.require(:event).permit(:title, :start, :end)
  end

  helper_method :event
end
