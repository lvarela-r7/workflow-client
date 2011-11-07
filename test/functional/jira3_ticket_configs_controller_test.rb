require 'test_helper'

class Jira3TicketConfigsControllerTest < ActionController::TestCase
  setup do
    @jira3_ticket_config = jira3_ticket_configs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:jira3_ticket_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create jira3_ticket_config" do
    assert_difference('Jira3TicketConfig.count') do
      post :create, :jira3_ticket_config => @jira3_ticket_config.attributes
    end

    assert_redirected_to jira3_ticket_config_path(assigns(:jira3_ticket_config))
  end

  test "should show jira3_ticket_config" do
    get :show, :id => @jira3_ticket_config.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @jira3_ticket_config.to_param
    assert_response :success
  end

  test "should update jira3_ticket_config" do
    put :update, :id => @jira3_ticket_config.to_param, :jira3_ticket_config => @jira3_ticket_config.attributes
    assert_redirected_to jira3_ticket_config_path(assigns(:jira3_ticket_config))
  end

  test "should destroy jira3_ticket_config" do
    assert_difference('Jira3TicketConfig.count', -1) do
      delete :destroy, :id => @jira3_ticket_config.to_param
    end

    assert_redirected_to jira3_ticket_configs_path
  end
end
