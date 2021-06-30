require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:events) }
  describe 'methods' do
    describe 'author?' do
      let(:event) { create(:event) }
      let(:user) { create(:user) }

      it 'ensures user creating answer is author' do
        expect(event.user.author?(event)).to be true
      end

      it 'ensures random user is not author' do
        expect(user.author?(event)).to be false
      end
    end
    describe 'conditional_name' do
      let(:user_no_name) { create(:user) }
      let(:user_with_name) { create(:user, name: 'test') }

      it 'returns capitalized email name if name is nil' do
        expect(user_no_name.conditional_name).to eq 'User'
      end

      it 'returns capitalized name if name is not blank' do
        expect(user_with_name.conditional_name).to eq 'Test'
      end
    end
  end
end
