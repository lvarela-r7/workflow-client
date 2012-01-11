require 'test_helper'

class SoapTicketConfigControllerTest < ActionController::TestCase
  setup do
    @soap_ticket_config = remedy_ticket_configs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:soap_ticket_config)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create remedy_ticket_config" do
    assert_difference('RemedyTicketConfig.count') do
      post :create, :soap_ticket_config => @soap_ticket_config.attributes
    end

    assert_redirected_to remedy_ticket_config_path(assigns(:soap_ticket_config))
  end

  test "should show remedy_ticket_config" do
    get :show, :id => @soap_ticket_config.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @soap_ticket_config.to_param
    assert_response :success
  end

  test "should update remedy_ticket_config" do
    put :update, :id => @soap_ticket_config.to_param, :soap_ticket_config => @soap_ticket_config.attributes
    assert_redirected_to remedy_ticket_config_path(assigns(:soap_ticket_config))
  end

  test "should destroy remedy_ticket_config" do
    assert_difference('RemedyTicketConfig.count', -1) do
      delete :destroy, :id => @soap_ticket_config.to_param
    end

    assert_redirected_to remedy_ticket_configs_path
  end
end
