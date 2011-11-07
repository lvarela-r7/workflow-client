require 'test_helper'

class TicketRulesControllerTest < ActionController::TestCase
  setup do
    @ticket_rule = ticket_rules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ticket_rules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ticket_rule" do
    assert_difference('TicketRule.count') do
      post :create, :ticket_rule => @ticket_rule.attributes
    end

    assert_redirected_to ticket_rule_path(assigns(:ticket_rule))
  end

  test "should show ticket_rule" do
    get :show, :id => @ticket_rule.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @ticket_rule.to_param
    assert_response :success
  end

  test "should update ticket_rule" do
    put :update, :id => @ticket_rule.to_param, :ticket_rule => @ticket_rule.attributes
    assert_redirected_to ticket_rule_path(assigns(:ticket_rule))
  end

  test "should destroy ticket_rule" do
    assert_difference('TicketRule.count', -1) do
      delete :destroy, :id => @ticket_rule.to_param
    end

    assert_redirected_to ticket_rules_path
  end
end
