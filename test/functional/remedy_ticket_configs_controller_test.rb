require 'test_helper'

class RemedyTicketConfigsControllerTest < ActionController::TestCase
  setup do
    @remedy_ticket_config = remedy_ticket_configs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:remedy_ticket_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create remedy_ticket_config" do
    assert_difference('RemedyTicketConfig.count') do
      post :create, :remedy_ticket_config => @remedy_ticket_config.attributes
    end

    assert_redirected_to remedy_ticket_config_path(assigns(:remedy_ticket_config))
  end

  test "should show remedy_ticket_config" do
    get :show, :id => @remedy_ticket_config.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @remedy_ticket_config.to_param
    assert_response :success
  end

  test "should update remedy_ticket_config" do
    put :update, :id => @remedy_ticket_config.to_param, :remedy_ticket_config => @remedy_ticket_config.attributes
    assert_redirected_to remedy_ticket_config_path(assigns(:remedy_ticket_config))
  end

  test "should destroy remedy_ticket_config" do
    assert_difference('RemedyTicketConfig.count', -1) do
      delete :destroy, :id => @remedy_ticket_config.to_param
    end

    assert_redirected_to remedy_ticket_configs_path
  end
end
