class StaticPagesController < ApplicationController
  def home
  	@a = 5
  end

  def help
  end

  def about
  
  end

  def contact
  
  end

  def down
    send_file Rails.root.to_s + '/../imagenet_demo/synset_words.txt', :type=>"application/txt", :x_sendfile=>true
  end

end
