class WelcomeController < ApplicationController

  require 'rubygems'
  require 'mechanize'

  def index
  end

  def designer_scrape
    @states = ["AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VI","VA","WA","WV","WI","WY"]
    agent = Mechanize.new
    agent.get("http://www.dsasociety.org/designer_locator.cfm")
    @form = agent.page.forms.first
    @fields = @form.fields.last
    @states.each do |state|
      @form.fields.last.value = state
      @page  = @form.submit
      @doc = Nokogiri::HTML(@page.body)
      @doc.css('#member_profile').each do |tb|
        @temp ={}
        @add=""
        @rows = tb.css('tr').length
        for row in 0..(@rows-1)
          @tr = tb.css('tr')[row]
          if row==0
            @temp["name"] = @tr.css('td').text
          elsif row==1
            @temp["contact"] = @tr.css('td').text
          elsif row==2
            @temp["email"] = @tr.css('td').text
          else
            if row==(@rows-1)
              @temp["pin"] = @tr.css('td').text.split(',').last.split(' ').last
              @add<<" #{@tr.css('td').text.split(',').first}"
              @temp["address"]=@add.strip
            else
              @add <<" #{@tr.css('td').text}"
            end
          end
        end
        @temp["state"]=state
        if !Designer.exists?(:email=>@temp["email"])
          Designer.create(@temp)
        else
          p "---------#{@temp["name"]}---dublicate------Not saved-------"
        end
      end
    end
  end
end
