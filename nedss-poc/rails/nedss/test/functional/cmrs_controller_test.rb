require File.dirname(__FILE__) + '/../test_helper'

class CmrsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:cmrs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_cmr
    assert_difference('Cmr.count') do
      post :create, :cmr => {:first_name => "Robert" }
    end
    
    assert_redirected_to cmr_path(assigns(:cmr))
  end

  def test_should_show_cmr
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_cmr
    put :update, :id => 1, :cmr => { }
    assert_redirected_to cmr_path(assigns(:cmr))
  end

  def test_should_destroy_cmr
    assert_difference('Cmr.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to cmrs_path
  end
end
