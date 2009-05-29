require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/sessions_controller'

# Re-raise errors caught by the controller.
class Admin::SessionsController; def rescue_action(e) raise e end; end

class Admin::SessionsControllerTest < ActionController::TestCase

  fixtures :users

  def test_should_login_and_redirect
    user = Factory(:user)
    post :create, :login => user.login, :password => user.password
    assert session[:user_id]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user_id]
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

  def test_should_remember_me
    user = Factory(:user)
    @request.cookies["auth_token"] = nil
    post :create, :login => user.login, :password => user.password, :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    @request.cookies["auth_token"] = nil
    post :create, :login => 'quentin', :password => 'monkey', :remember_me => "0"
    assert @response.cookies["auth_token"].blank?
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :destroy
    assert @response.cookies["auth_token"].blank?
  end

  def test_should_login_with_cookie
    user = Factory(:user)
    user.remember_me
    @request.cookies["auth_token"] = cookie_for(user)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    user = Factory(:user)
    user.remember_me
    user.update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(user)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    Factory(:user).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token user.remember_token
    end
end
