# Rails Scheduler Configuration File (Equivalent to Laravel's Console/Kernel.php)
# Learn more: http://github.com/javan/whenever

# Direct task execution outputs to log/cron_auto_complete.log
set :output, "log/cron_auto_complete.log"

# Define the project environment (development for demo purposes)
set :environment, "development"

# Run the auto_complete rake task at minutes 00 and 30 of every hour
every "0,30 * * * *" do
  rake "bookings:auto_complete"
end
