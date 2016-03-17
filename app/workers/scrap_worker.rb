class ScrapWorker
  include Sidekiq::Worker
  include ApplicationHelper

  def perform
  	hospitals_data_scrape
  end
end

