require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)

require 'clockwork'

module Clockwork
  configure do |config|
    config[:logger] = Logger.new('/var/log/clockwork.log')
  end

  # every(3.hours, 'course.sync') { CourseSyncWorker.perform_async }

  # every(10.minutes, 'group.state_check.end') { GroupEndCheckWorker.perform_async }
  # every(10.minutes, 'group.state_check.ready') { GroupReadyCheckWorker.perform_async }

  # every(10.minutes, 'package.state_check.paid') { PackagePaidCheckWorker.perform_async }

  # every(10.minutes, 'bill.test_autopay.pay') { TestingBillWorker.perform_async }

  every( 1.day , 'change_daily_question', :at => '12:00' ) { ChatDailyQuestionJob.perform_later }
end
