require 'test_helper'

class TicketConfigsControllerTest < ActionController::TestCase
  setup do
    @ticket_config = ticket_configs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ticket_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ticket_config" do
    assert_difference('TicketConfig.count') do
      post :create, :ticket_config => @ticket_config.attributes
    end

    assert_redirected_to ticket_config_path(assigns(:ticket_config))
  end

  test "should show ticket_config" do
    get :show, :id => @ticket_config.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @ticket_config.to_param
    assert_response :success
  end

  test "should update ticket_config" do
    put :update, :id => @ticket_config.to_param, :ticket_config => @ticket_config.attributes
    assert_redirected_to ticket_config_path(assigns(:ticket_config))
  end

  test "should destroy ticket_config" do
    assert_difference('TicketConfig.count', -1) do
      delete :destroy, :id => @ticket_config.to_param
    end

    assert_redirected_to ticket_configs_path
  end
end
