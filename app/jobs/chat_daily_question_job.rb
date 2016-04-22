class ChatDailyQuestionJob < ActiveJob::Base
  queue_as :default

  def perform

		@chat_daily_quesiton = ChatDailyQuestion.find_by("DATE(send_at) = ?", Date.today)
		if @chat_daily_quesiton.present?
	    results = HTTParty.post(
	      'http://chat.colorgy.io/questions/schedule_question',
	      verify: false,
	      headers: { 'Content-Type' => 'application/json' },
	      body: { question: @chat_daily_quesiton.question, dateString: @chat_daily_quesiton.send_at.strftime('%Y/%m/%d') }.to_json
	    )
		else
		end

  end
end
