class CreateChatDailyQuestions < ActiveRecord::Migration
  def change
    create_table :chat_daily_questions do |t|
      t.string :question
      t.datetime :send_at

      t.timestamps null: false
    end
  end
end
