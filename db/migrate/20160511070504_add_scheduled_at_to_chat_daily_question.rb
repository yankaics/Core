class AddScheduledAtToChatDailyQuestion < ActiveRecord::Migration
  def change
    add_column :chat_daily_questions, :scheduled_at, :datetime
  end
end
