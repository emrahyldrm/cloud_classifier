require 'test_helper'

class ClassifierRequestControllerTest < ActionDispatch::IntegrationTest
  test "should get req" do
    get classifier_request_req_url
    assert_response :success
  end

  test "should get result" do
    get classifier_request_result_url
    assert_response :success
  end

end
