class WelcomeController < ApplicationController


  def index
  end

  def hospital_scrape
    ScrapWorker.perform_async
    redirect_to :back
  end
end
