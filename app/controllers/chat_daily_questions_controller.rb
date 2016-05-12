class ChatDailyQuestionsController < ApplicationController
	# before_action :authenticate_admin!

	def index
		@questions = ChatDailyQuestion.all.order("created_at DESC")
	end

	def edit
		@question = ChatDailyQuestion.find(params[:id])
	end

	def update
		@question = ChatDailyQuestion.find(params[:id])
		@question.update(questions_params)
		redirect_to chat_daily_questions_path
	end

	def new
		@question = ChatDailyQuestion.new
	end

	def create
		@question = ChatDailyQuestion.create(questions_params)
		redirect_to chat_daily_questions_path
	end

	def destroy
		@question = ChatDailyQuestion.find(params[:id])
		@question.destroy
		redirect_to chat_daily_questions_path
	end

	private

	def questions_params
		params.require(:chat_daily_question).permit(:question, :scheduled_at)
	end
end
