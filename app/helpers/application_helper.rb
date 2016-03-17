module ApplicationHelper
  require 'rubygems'
  require 'nokogiri'
  require 'open-uri'
  require 'mechanize'
  
  def hospitals_data_scrape
    @states = ["al", "ak", "az", "ar", "ca", "co", "ct", "de", "dc", "fl", "ga", "hi", "id", "il", "in", "ia", "ks", "ky", "la", "me", "md", "ma", "mi", "mn", "ms", "mo", "mt", "ne", "nv", "nh", "nj", "nm", "ny", "nc", "nd", "oh", "ok", "or", "pa", "ri", "sc", "sd", "tn", "tx", "ut", "vt", "vi", "va", "wa", "wv", "wi", "wy"] 
    @links = []
    @states.each do |s|
      url =  "http://health.usnews.com/best-hospitals/area/#{s}"
      begin
        doc = Nokogiri::HTML(open(url))
        if doc.at_css('p.t-slack').present?
          @city_desc = doc.at_css('p.t-slack').text
          @temp = @city_desc.split('.')[0].split(' ')
          @total = @temp[@temp.length-2].to_i
          p = (@total/10.0) 
          @pages= p > p.round ? p.round+1 : p.round
          p "--========================================================-Total pages---================================================#{@pages}"
          for i in 1..@pages
            if i==1
              hospital_links = doc.css('.h-flush a')
              if hospital_links.present?
                hospital_links.each do |h|
                  # p "--------#{h[:href]}"
                  begin
                    data = hospital_data(h[:href])
                  rescue
                    p "XXXXXXXXXXXX----skip----link--#{h}"
                  end
                end
              end
            else
              page_url="http://health.usnews.com/best-hospitals/area/#{s}?page=#{i}"
              sub_doc=Nokogiri::HTML(open(page_url))
              hospital_links = sub_doc.css('.h-flush a')
              if hospital_links.present?
                hospital_links.each do |h|
                  # p "--------#{h[:href]}"
                  begin
                    data = hospital_data(h[:href])
                  rescue
                    p "XXXXXXXXXXXX----skip----link--#{h}"
                  end                    
                end
              end
              sleep [7,4].sample
            end
          end
        end
      rescue =>e
        p "------XXXXXXXXXXx----#{e.backtrace}------#{s}---NOT FOUND--------"
      end
      sleep [4,5].sample
    end
  end

  def hospital_data hospital_link
    url = "http://health.usnews.com#{hospital_link}"
    doc= Nokogiri::HTML(open(url))
    @hospital={}
    @hospital["name"]=doc.at_css('.h-normal').text.gsub("\n","").strip
    @hospital["city"]=doc.at_css('.item:nth-child(1) p:nth-child(2)').present? ? doc.at_css('.item:nth-child(1) p:nth-child(2)').text.split(',')[0].gsub("\n","").strip : hospital_link.split('/')[2]
    @hospital["state"]=hospital_link.split('/')[3]
    @hospital["trauma_center"]=doc.at_css('.item:nth-child(2) p:nth-child(2)').present? ? doc.at_css('.item:nth-child(2) p:nth-child(2)').text.gsub("\n","").strip : "No"
    @hospital["hospital_type"]=doc.at_css('.item:nth-child(1) p:nth-child(4)').present? ? doc.at_css('.item:nth-child(1) p:nth-child(4)').text.gsub("\n","").strip : "n/a"
    @hospital["beds"]=doc.at_css('#content :nth-child(2) p:nth-child(4)').present? ? doc.at_css('#content :nth-child(2) p:nth-child(4)').text.gsub("\n","").strip : "n/a"
    @hospital["description"]=doc.at_css('.maincontent .sep:nth-child(2) p').present? ? doc.at_css('.maincontent .sep:nth-child(2) p').text.gsub("\n","").strip : "n/a"
    @ranking=doc.css('.block .media_content')
    if @ranking.present?
      @r=[]
      @ranking.each do |r|
        @r<<r.text.gsub("\n","").gsub("  ","").strip
      end
      @hospital["ranking"]= @r
    end
    @specialties= doc.css('.sep .sep .block')
    if @specialties.present?
      @s =[]
      @specialties.each do |s|
        @s<<s.text.gsub("\n","").strip
      end
      @hospital["specialties"]=@s
    end  

    contact_url="#{url}/contact"
    begin
      newdoc= Nokogiri::HTML(open(contact_url))
      @add=newdoc.at_css('#content .block p:nth-child(2)').text.gsub("\n","").strip.split('  ')
      p "-------------address---#{@add}"
      @hospital["address"]="#{@add[0]} #{@hospital['city']}"
      @hospital["pin"]=@add.last.split(' ').last
      @hospital["country"]="USA"
      @hospital["contact"]=newdoc.at_css('p:nth-child(6)').text.gsub("\n","").strip
      @hospital["link"]=newdoc.at_css('.media_content a').text.gsub("\n","").strip
    rescue => e
      p "---EEEEEEEEEEEEE------#{e.backtrace}"
    end
    if !Hospital.exists?(:name=>@hospital["name"],:pin=>@hospital["pin"])
      @h=Hospital.create!(@hospital)
      p "********#{@h.id}**#{@h.state}**#{@h.name}*****"
    else
      @h = Hospital.find_by_name_and_pin(@hospital["name"],@hospital["pin"])
      @h.update_attributes(@hospital)
    end
  end 
end
