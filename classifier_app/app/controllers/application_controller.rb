class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  $classifier_images_path = "/app/assets/images/classifier_images/"
end
