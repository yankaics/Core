class ChatDailyQuestionJob < ActiveJob::Base
  queue_as :default

  def perform

		@chat_daily_quesiton = ChatDailyQuestion.find_by("scheduled_at >= ? AND scheduled_at <= ?", Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
		if @chat_daily_quesiton.present? && @chat_daily_quesiton.send_at.nil?
	    results = HTTParty.post(
	      'http://chat.colorgy.io/questions/schedule_question',
	      verify: false,
	      headers: { 'Content-Type' => 'application/json' },
	      body: { question: @chat_daily_quesiton.question, dateString: @chat_daily_quesiton.scheduled_at.strftime('%Y/%-m/%d') }.to_json
	    )
      @chat_daily_quesiton.send_at = Time.zone.now
      @chat_daily_quesiton.save
		else
		end

  end
end
