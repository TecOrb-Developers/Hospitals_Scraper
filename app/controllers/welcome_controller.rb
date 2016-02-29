class WelcomeController < ApplicationController
require 'open-uri'
require 'csv'

require 'rubygems'
require 'mechanize'

  def index

	 @tests = Scrape.all.order(id: "DESC").paginate(:page => params[:page], :per_page => 10)

  	# respond_to do |format|
	  #   format.html
	  #   format.csv do
	  #     headers['Content-Disposition'] = "attachment; filename=\"lodging.csv\""
	  #     headers['Content-Type'] ||= 'text/csv'
	  #   end
  	# end
  end

  def new
  	 ScrapWorker.perform_async
  	 redirect_to :back
  end

  def generate_csv
  	@data = Scrape.all
  	headers = ["link","name","rating","street_address","extended_address","city","state","pin","star","price","total_reviews","Traveller_rating","description","amenities","photos","reviews","rooms"] 

  	CSV.open('file.csv', 'w' ) do |writer|
  		writer << headers
  		@data.each do |record|
   			row = [record.link.strip,record.name.strip,record.rating.strip,record.s_address.strip,record.e_address.strip,record.city.strip,record.state.strip,record.pin.strip,record.star.strip,record.price.strip,record.total_reviews.strip,record.traveller_rating,record.description.strip,record.amenities,record.photos,record.reviews,record.rooms]
  			writer <<  row
  			p "--------------------------"
  		end
  	end
  end

  def gsa_new
    @states = ["Alabama","Alaska","American Samoa","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","District of Columbia","Florida","Georgia","Guam","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Puerto Rico","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virgin Islands","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]
    agent = Mechanize.new
    agent.get("http://www.gsa.gov/portal/category/100120")
    @form = agent.page.forms[2]
    @states.each do |state|
      @form.fields.last.value = state
      @page  = @form.submit
      doc = Nokogiri::HTML(@page.body)
      @result = []
      @temp = 0
      @destination = {}
      doc.css('td').each do |t|
        case @temp 
        when 0   
          @destination[:state] = state
          @destination[:primary_destination] = t.text
        when 1  
          @destination[:county] = t.text
        when 2
          @destination[:oct] = "2015;#{t.text}"
        when 3
          @destination[:nov] = "2015;#{t.text}"
        when 4
          @destination[:dec] = "2015;#{t.text}"
        when 5
          @destination[:jan] = "2016;#{t.text}"
        when 6
          @destination[:feb] = "2016;#{t.text}"
        when 7
          @destination[:mar] = "2016;#{t.text}"
        when 8
          @destination[:apr] = "2016;#{t.text}"
        when 9
          @destination[:may] = "2016;#{t.text}"
        when 10
          @destination[:jun] = "2016;#{t.text}"
        when 11
          @destination[:jul] = "2016;#{t.text}"
        when 12
          @destination[:aug] = "2016;#{t.text}"
        when 13
          @destination[:sep] = "2016;#{t.text}"
        when 14
          @destination[:mim] = "2016;#{t.text}"
        end
        @temp +=1
        if @temp==15
          @temp =0
          @gsa = GsaRate.where(:state=>@destination[:state],:primary_destination=>@destination[:primary_destination]).first
          if !@gsa.present?
           GsaRate.create(@destination)
          end 
          @result << @destination       
          @destination = {}
        end      
      end
    end
  end

  def fema_code
    @statecodes = [1, 39, 60, 2, 40, 48, 41, 3, 5, 4, 59, 6, 7, 54, 8, 10, 47, 11, 9, 46, 12, 13, 16, 15, 14, 17, 18, 45, 19, 20, 22, 26, 23, 24, 25, 43, 21, 44, 53, 27, 28, 42, 29, 30, 56, 58, 31, 49, 32, 33, 50, 55, 34, 36, 35, 37, 38, 52, 51]
    @statecodes.each do |sc|
      url= "https://apps.usfa.fema.gov/hotel/main/searchResults?max=10&ff_city=&ff_zip=&ff_state_ID=#{sc}&searchType=Basic&offset=0&ff_property_name="
      doc = Nokogiri::HTML(open(url))
      @totalrecords=doc.at_css(".text-muted").present? ? doc.at_css(".text-muted").text.split(" ")[0].to_f : 0
      if @totalrecords > 0
        p = (@totalrecords/100) 
        @pages= p > p.round ? p.round+1 : p.round
        p "------------total pages----#{@pages}"
        for i in 1..@pages
          suburl= "https://apps.usfa.fema.gov/hotel/main/searchResults?max=100&ff_city=&ff_zip=&ff_state_ID=#{sc}&searchType=Basic&offset=#{(i-1)*100}&ff_property_name="
          p ".......suburl ----#{suburl}"
          @maindoc= Nokogiri::HTML(open(suburl))
          @data = @maindoc.xpath('//section[@class="container"]/table[@class="tablesaw-stack"]/tbody/tr/td/a/@href')
          if @data.present?
            @t=0
            @data.each do |e|
              p "--#{@t+=1}-ele--#{e.to_s.split('=')[1]}"
              @property_id = e.to_s.split('=')[1]
              if !FemaCode.exists?(:state_id=>sc,:property_id=> @property_id)
                @property_url= "https://apps.usfa.fema.gov/hotel/main/resultsDetail?propertyID=#{@property_id}"
                @property_doc = Nokogiri::HTML(open(@property_url))
                @property = {}
                @property[:property_id] = @property_id
                @property[:property_name] = @property_doc.at_css('#skipnav').present? ? @property_doc.at_css('#skipnav').text : nil
                @property[:fema_id] = @property_doc.at_css('section p').present? ? @property_doc.at_css('section p').text.split(':')[1].strip : nil
                # @add = @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Address")]').present? ? @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Address")]')[0].next_element.text.gsub("\n","").split(' ') : nil
                @property[:address]=  @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Address")]').present? ? @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Address")]')[0].next_element.text.gsub("\n","").strip : nil
                @property[:pin] = @property[:address]!=nil ? @property[:address].split(' ').last : nil
                @property[:state_code] = @property[:address]!=nil ? @property[:address].split(' ')[@property[:address].split(' ').length-2] : nil
                @property[:state_id] = sc
                @property[:state] = @property[:address]!=nil ? @property[:address].split(' ')[@property[:address].split(' ').length-2] : nil
                @property[:city] = @property[:address]!=nil ? @property[:address].split(' ')[@property[:address].split(' ').length-3] : nil
                @property[:details] = @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Details")]').present? ? @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Details")]')[0].next_element.text.gsub("\n","").strip : nil
                @property[:phone] = @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Phone number")]').present? ? @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Phone number")]')[0].next_element.text.gsub("\n","").strip : nil
                @property[:email] = @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Email")]').present? ? @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Email")]')[0].next_element.text.gsub("\n","").strip : nil
                @property[:website] = @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Website")]').present? ? @property_doc.xpath('//section[@class="container"]/dl/dt[contains(text(), "Website")]')[0].next_element.text.gsub("\n","").strip : nil
                FemaCode.create(@property)
                p "------------------------------#{@property.inspect}"
              end
            end
          end
        end
      end
    end
  end

end
