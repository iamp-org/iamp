class TriggerIamJob < ApplicationJob
  queue_as :default

  def perform(role)
    # puts "Processing job with args: #{role.inspect}"
    if Rails.env.development?
      puts 'This task must not run in development mode'
      return
    end
    AccessProvisionService.run(role)
  end
end
