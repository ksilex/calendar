require 'rails_helper'

RSpec.describe RecurringEventsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  describe 'GET #index' do
    let(:current_user) { create(:user) }
    let!(:events) { create_list(:event, 3, user_id: current_user.id) }
    let!(:recurring_events) { create_list(:event, 3, user_id: current_user.id, frequency: 'daily') }
    let!(:other_user_events) { create_list(:event, 3, user_id: user.id) }
    let!(:out_of_range_event_n1) { create(:event, frequency: 'daily', start: '1980-01-01', end: '1999-01-01', user_id: current_user.id) }
    let!(:out_of_range_event_n2) { create(:event, frequency: 'daily', start: '2025-01-01', end: '2030-01-01', user_id: current_user.id) }
    before do
      login(current_user)
      get :index, params: { start: '2007-01-01', end: '2022-01-01' }, format: :json
    end

    it 'ensures user gets only his ocurring events' do
      expect(assigns(:events)).to match_array(recurring_events)
    end
  end
  describe 'GET #all' do
    let(:current_user) { create(:user) }
    let!(:events) { create_list(:event, 3, user_id: current_user.id) }
    let!(:recurring_events) { create_list(:event, 3, user_id: current_user.id, frequency: 'daily') }
    let!(:other_user_recurring_events) { create_list(:event, 3, user_id: user.id, frequency: 'daily') }
    let!(:out_of_range_event_n1) { create(:event, frequency: 'daily', start: '1980-01-01', end: '1999-01-01') }
    let!(:out_of_range_event_n2) { create(:event, frequency: 'daily', start: '2025-01-01', end: '2030-01-01') }
    before do
      login(current_user)
      get :all, params: { start: '2007-01-01', end: '2022-01-01' }, format: :json
    end

    it 'ensures user gets all ocurring events' do
      expect(assigns(:events)).to match_array(recurring_events + other_user_recurring_events)
    end
  end

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves a new recurring event in the database' do
        expect { post :create, params: { recurring_event: attributes_for(:event, frequency: 'daily') } }.to change(Event, :count).by(1)
      end
    end
    context 'with invalid attributes' do
      it 'does not save the recurring event' do
        expect { post :create, params: { recurring_event: attributes_for(:event, :invalid_event) } }.to_not change(Event, :count)
        expect(response.status).to eq 422
      end
    end
  end

  describe 'PATCH #update' do
    context 'with user being author' do
      before { login(event.user) }

      context 'with valid attributes' do
        it 'changes event attributes' do
          patch :update, params: { id: event.id, recurring_event: { title: 'new title' } }
          event.reload
          expect(event.title).to eq 'new title'
        end
      end

      context 'with invalid attributes' do
        before { patch :update, params: { id: event.id, recurring_event: attributes_for(:event, :invalid_event) } }

        it 'does not change event' do
          event.reload
          expect(event.title).to eq event.title
        end
      end
    end
    context 'with user not being author' do
      before { login(user) }
      it 'does not changes event attributes' do
        patch :update, params: { id: event.id, recurring_event: { title: 'new title' } }
        event.reload
        expect(event.title).to eq event.title
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with user being author' do
      before { login(event.user) }

      it 'deletes the event' do
        expect { delete :destroy, params: { id: event.id } }.to change(Event, :count).by(-1)
      end
    end

    context 'with user not being author' do
      before do
        event
        login(user)
      end

      it 'does not deletes the event' do
        expect { delete :destroy, params: { id: event.id } }.to_not change(Event, :count)
      end
    end
  end
end
