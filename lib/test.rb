require 'anemone'
require 'mongo'
 
# Patterns
#POST_WITHOUT_SLASH  = %r[[^\/]+$]   # http://isbullsh.it/2012/66/here-is-a-title  (301 redirects to slash)
#POST_WITH_SLASH     = %r[[\w-]+\/$] # http://isbullsh.it/2012/66/here-is-a-title/
#ANY_POST            = Regexp.union POST_WITHOUT_SLASH, POST_WITH_SLASH
ANY_PAGE            = %r[\.cms$]               # http://isbullsh.it/page/4 
#ANY_PATTERN         = Regexp.union ANY_PAGE, ANY_POST
 
# MongoDB
db = Mongo::Connection.new.db("scraped")
posts_collection = db["posts"]

toi = "http://timesofindia.indiatimes.com/cricket"

bullshit = "http://isbullsh.it"
 
Anemone.crawl(toi) do |anemone|
   
  anemone.focus_crawl do |page| 
    page.links.keep_if { |link| link.to_s.match(ANY_PAGE) } # crawl only links that are pages or blog posts
  end
  
  anemone.on_every_page do |page|
    puts "Searching #{page.url}"
    
    #check if already crawled
     if not posts_collection.find_one( :url => page.url.to_s)
      
      publishDate =""
      author =""
      tags=""
      channel=""
      catergory=""
      sub_catergory=""
      
      
    
      # TODO Search Script Tag for META Info
      if page.doc
        page.doc.css('script').each do |script|
          
          temp_publishDate = script.content.match(/var _iBeat_articledt="(\S*) (.*)/)
          if not temp_publishDate.nil?
            publishDate = temp_publishDate[2][0, temp_publishDate[2].length - 2] 
          end
          
          temp_author = script.content.match(/var _iBeat_author="(\S*) (.*)/)
          if not temp_author.nil?
            author = temp_author[2][0, temp_author[2].length - 2] 
          end
          
          temp_tags = script.content.match(/var _iBeat_tag='(\S*) (.*)/)
          if not temp_tags.nil?
            tags = temp_tags[2][0, temp_tags[2].length - 2] 
          end
          
          temp_channel = script.content.match(/var _iBeat_channel ="(\S*) (.*)/)
          if not temp_channel.nil?
            channel = temp_channel[2][0, temp_channel[2].length - 2] 
          end
          
          temp_catergory = script.content.match(/ var _iBeat_cat=trim\('(\S*) (.*)/)
          if not temp_catergory.nil?
            catergory = temp_catergory[2][0, temp_catergory[2].length - 3]
          end
          
          temp_sub_catergory = script.content.match(/var _iBeat_subcat=trim\('(\S*) (.*)/)
          if not temp_sub_catergory.nil?
            sub_catergory = temp_sub_catergory[2][0, temp_sub_catergory[2].length - 3] 
          end
        end
      end
    
      title = page.doc.at_xpath("//span[@class='arttle']/h1").text rescue nil
      tag = page.doc.at_xpath("//span[@class='byline']").text rescue nil
    
      article = page.doc.at_xpath("//div[@class='clearFix']/div[contains(@class,'Normal')]/div[@class='Normal']").text rescue nil
      #exception unable to catch
      if not article.nil?
        if article.include? "doweshowbellyad=0;" 
           article = nil       
         end
      end
    
      image = page.doc.at_css("div.flL_pos img")['src'] rescue nil
    
      url = page.url.to_s
    
      if title and article
        
        post = {title: title, tag: tag, article: article, image: image, url: url, publishdate: publishDate, author: author, tags: tags, channel: channel, catergory: catergory, sub_catergory: sub_catergory}
        puts "Inserting #{post.inspect}"
        posts_collection.insert post
      end
      
      
    else
      puts "I KNOW YOU"
    #end check already crawled  
    end
    
  #end on_every_pag  
  end
  
  
  
end

