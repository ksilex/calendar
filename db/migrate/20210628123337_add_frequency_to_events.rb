class AddFrequencyToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :frequency, :integer, default: nil
  end
end
