require 'open3'
require 'open-uri'
require 'fileutils'
require 'pathname'
include  ClassifierRequestHelper


class ClassifierRequestController < ApplicationController

  def url_valid?(url)
    url = URI.parse(url) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end 


  def req
    if params[:error] then
      @error_message = params[:error]
    end
    if !classifier_running? then
      redirect_to root_path
    end
  end


  def image_valid?(path)
    begin
      FastImage.type(path,  :raise_on_failure=>true)
    rescue
        if Pathname.new(path).file? 
          FileUtils.rm(path)
        end
      return false
    end
    return true
  end


  def find_enlosing_image(path)
    dim = FastImage.size(path)
    cols = dim[0]
    rows = dim[1]

    if rows > 480
      scale_f = rows / 480
      rows = rows / scale_f
      cols = cols / scale_f
      Open3.capture3("convert -resize " + cols.to_s + "X" + rows.to_s + " " + path + " " + path)
    end
  end


  def result
  	@name = params[:img]

    dir = Rails.root.to_s + $classifier_images_path
    classifier = Rails.root.to_s + "/../imagenet_demo/client.py"
    path = File.join(dir, @name)
    find_enlosing_image(path)

    @call = "python " + classifier + " " + path
    stdout, stderr, status = Open3.capture3(@call)
    output = stdout
    output["\n"] = ""
    r = output.split("-")
    @prob    = r[0][0..4]
    @res     = r[1].split(", ")
    @elapsed = r[2][0..3]

    if logged_in?
      nr = Request.new(user_id: current_user[:id], name: @name, result: @res, prob: @prob)
      nr.save
    else
      nr = Request.new(user_id: -1, name: "guest", result: @res, prob: @prob)
      nr.save
    end

  end


  def create

    if !classifier_running? then
      redirect_to root_path

    elsif params[:upload] && params[:upload][:file] then      # if an image uploaded
    	name = params[:upload][:file].original_filename
    	dir = Rails.root.to_s + $classifier_images_path
    	date = DateTime.now
    	name = date.strftime('%b_%d_%Y_%H_%M_%S_') + name

    	path = File.join(dir, name)
      File.open(path, "wb") { |f| f.write(params[:upload][:file].read) }   

      if image_valid?(path) then
        redirect_to result_path(img: name)
      else
        redirect_to request_path(error: 'n_val')
      end

      # if this is a url request
    elsif  (params[:upload] && params[:upload][:url]) && params[:upload][:url] != 0 && 
            params[:upload][:url] != ".. or enter an url here" then      
      url = params[:upload][:url]

      if url_valid?(url) then
          dir = Rails.root.to_s + $classifier_images_path
          date = DateTime.now
          name = date.strftime('%b_%d_%Y_%H_%M_%S_url_request.jpg')

          path = File.join(dir, name)

          open(path, 'wb') do |file|
            file << open(url).read
          end

          if image_valid?(path) then
            redirect_to result_path(img: name)
          else
            redirect_to request_path(error: 'n_val')
          end
      else
        redirect_to request_path(error: 'url')
      end

    else
      redirect_to request_path(error: 'path')
    end


	end
end
