require 'open3'
require 'open-uri'
#require 'fastimage'

class ClassifierRequestController < ApplicationController

  def url_valid?(url)
    url = URI.parse(url) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end 

  def req
    if params[:error] then
      @error_message = params[:error]
    end
  end


  def result
  	@name = params[:img]

    dir = Rails.root.to_s + "/app/assets/images/classifier_images/"
    classifier = Rails.root.to_s + "/../imagenet_demo/client.py"
    path = File.join(dir, @name)
    @call = "python " + classifier + " " + path
    #x = system("python", classifier, path, out: $stdout, err: :out)
    stdout, stderr, status = Open3.capture3(@call)
    output = stdout
    output["\n"] = ""
    r = output.split("-")
    @prob = r[0][0..4]
    @res = r[1].split(", ")
    @elapsed = r[2][0..3]

    Request.new(user_id: current_user[:id], name: @name).save
  end


  def create
    # if an image uploaded
    if params[:upload] && params[:upload][:file] then
    	name = params[:upload][:file].original_filename
    	dir = Rails.root.to_s + "/app/assets/images/classifier_images/"
    	date = DateTime.now
    	name = date.strftime('%b_%d_%Y_%H_%M_%S_') + name

    	path = File.join(dir, name)
      File.open(path, "wb") { |f| f.write(params[:upload][:file].read) }   
      #@image_size = FastImage.size("http://stephensykes.com/images/ss.com_x.gif")
  		redirect_to result_path(img: name)

    # if this is a url rquest
    elsif  (params[:upload] && params[:upload][:url]) && params[:upload][:url] != 0 && params[:upload][:url] != ".. or enter an url here" then      
      url = params[:upload][:url]

      if url_valid?(url) then
          dir = Rails.root.to_s + "/app/assets/images/classifier_images/"
          date = DateTime.now
          name = date.strftime('%b_%d_%Y_%H_%M_%S_url_request.jpg')

          path = File.join(dir, name)
          
          open(path, 'wb') do |file|
            file << open(url).read
          end

          redirect_to result_path(img: name)
      else
        redirect_to request_path(error: 'url')
      end

    else
      redirect_to request_path(error: "path")
    end


	end
end
