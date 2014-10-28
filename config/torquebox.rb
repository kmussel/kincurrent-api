TorqueBox.configure do

  #queue '/queues/import_csv' do
  #  processor ImportProcessor
  #end
  puts "THE ENV = #{ENV.inspect}"
  env = ENV["RACK_ENV"] || "development"
  case env
  when "staging"
    puts "***Using bounded pools in STAGING"
    pool :jobs do
      type :bounded
      min 1
      max 1
      lazy false
    end
    pool :web do
      type :bounded
      min 1
      max 2
      lazy false
    end
    pool :messaging do
      type :bounded
      min 1
      max 1
      lazy false
    end

  # when "development", "test"
  #   puts "*** NOT Using bounded pools"
  else
    puts "***Using bounded pools in PROD"
    pool :jobs do
      type :shared
      min 1
      max 1
      lazy false
    end
    pool :web do
      type :shared
      min 2
      max 6
      lazy false
    end
    pool :messaging do
      type :shared
      min 1
      max 1
      lazy false
    end
    # job OrderStatuser do
    #   name 'order.statuser'
    #   # Fire at 4AM every day
    #   cron '0 0 4 * * ?'
    #   timeout '60s'
    #   singleton true
    # end
  end

  service RabbitmqService do
    singleton true
    config do
      # max_retries 10
    end
  end
  # 
  # job CardStatuser do
  #   name 'card.statuser'
  #   # Fire at 5AM every day
  #   cron '0 0 5 * * ?'
  #   timeout '60s'
  #   singleton true
  # end
  # 
  # job CardApprovalMailer do
  #   name 'card.approval_mailer'
  #   # Fire every 15 minutes
  #   cron '0 */15 * * * ?'
  #   timeout '120s'
  #   singleton true
  # end
  # 
  # job UssfReportRunner do
  #   name 'ussf.report_runner'
  #   # Fire at 2AM on the first of every month
  #   cron '0 0 2 1 * ?'
  #   timeout '600s'
  #   singleton true
  # end
end
