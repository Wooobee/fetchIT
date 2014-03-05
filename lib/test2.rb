require 'anemone'
require 'mongo'
 
# Patterns
POST_WITHOUT_SLASH  = %r[[^\/]+$]   # http://isbullsh.it/2012/66/here-is-a-title  (301 redirects to slash)
POST_WITH_SLASH     = %r[[\w-]+\/$] # http://isbullsh.it/2012/66/here-is-a-title/
ANY_POST            = Regexp.union POST_WITHOUT_SLASH, POST_WITH_SLASH
ANY_PAGE            = %r[page\/\d+]               # http://isbullsh.it/page/4 
ANY_PATTERN         = Regexp.union ANY_PAGE, ANY_POST
 
# MongoDB
db = Mongo::Connection.new.db("scraped")
posts_collection = db["posts"]

toi = "http://timesofindia.indiatimes.com/cricket"

bullshit = "http://isbullsh.it"
 
Anemone.crawl(bullshit) do |anemone|
   
  anemone.focus_crawl do |page| 
    page.links.keep_if { |link| link.to_s.match(ANY_POST) } # crawl only links that are pages or blog posts
  end
 
  anemone.on_every_page do |page|
    puts "Searching #{page.url}"
    
    puts "gefunden: #{posts_collection.find_one( {:url => page.url.to_s})} "
    
    #check if already crawled
    if not posts_collection.find_one( :url => page.url.to_s)
    
      if page.doc
    
        page.doc.css('script').each do |script|
      
        end
    
      end
    
      title = page.doc.at_xpath("//span[@class='arttle']/h1").text rescue nil
      tag = page.doc.at_xpath("//span[@class='byline']").text rescue nil
    
      article = page.doc.at_xpath("//div[@class='clearFix']/div[contains(@class,'Normal')]/div[@class='Normal']").text rescue nil
      article.delete("doweshowbellyad=0;") rescue nil
    
      image = page.doc.at_css("div.flL_pos img")['src'] rescue nil
    
      url = page.url.to_s
    
      post = {title: title, tag: tag, article: article, image: image, url: url}
      puts "Inserting #{post.inspect}"
      posts_collection.insert post
    
    else
      puts "I KNOW YOU"
    #end check already crawled  
    end
    
  #end on_every_pag  
  end
  
  
  
end

