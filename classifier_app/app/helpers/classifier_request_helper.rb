require 'open3'

module ClassifierRequestHelper
	
	def classifier_running?
    o, e, st = Open3.capture3("ps ax | grep server_classifier.py")
    ps_stat = o.to_s
    if ps_stat.include? "python server_classifier.py"
      return true
    else
      return false
    end

  end

end
