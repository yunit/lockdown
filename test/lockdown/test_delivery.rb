require 'helper'

class Authorization
  extend Lockdown::Access
end

class TestLockdown < MiniTest::Unit::TestCase

  def setup
    Lockdown::Configuration.reset
  end

  def test_it_allows_uri_without_ending_slash
    Authorization.permission :posts
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('/posts')
  end

  def test_it_allows_uri_with_ending_slash
    Authorization.permission :posts
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('/posts/')
  end

  def test_it_allows_uri_with_action
    Authorization.permission :posts
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('/posts/new')
  end

  def test_it_allows_uri_access_to_only_show
    Authorization.permission :posts do
      resource :posts do
        only :show
      end
    end
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal false, Lockdown::Delivery.allowed?('/postsshow')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/edit')
  end

  def test_it_allows_uri_access_to_all_except_show
    Authorization.permission :posts do
      resource :posts do
        except :show
      end
    end
    Authorization.public_access :posts

    assert_equal false, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal false, Lockdown::Delivery.allowed?('/postsshow')

    assert_equal true, Lockdown::Delivery.allowed?('/posts')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/edit')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/edit/')
  end

  def test_it_allows_uri_access_to_create_as_post
    Authorization.permission :posts do
      resource :posts do
        only :new, :create
      end
    end
    Authorization.public_access :posts


    assert_equal false, Lockdown::Delivery.allowed?('/posts')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/new')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/new/')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/create')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/create/')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/show/')
  end

  def test_it_allows_uri_access_to_update_as_put
    Authorization.permission :posts do
      resource :posts do
        only :show, :edit, :update
      end
    end
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('/posts/update')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/update/')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/edit')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/edit/')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/show/')

  end

  def test_it_denies_uri_access_to_destroy
    Authorization.permission :posts do
      resource :posts do
        except :destroy
      end
    end
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('/posts/update')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/edit')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/destroy')
  end

  def test_it_denies_uri_access_to_new_create_and_destroy
    Authorization.permission :users do
      resource :users do
        except :new, :create, :destroy
      end
    end
    Authorization.public_access :users

    assert_equal true, Lockdown::Delivery.allowed?('/users/show')

    assert_equal false, Lockdown::Delivery.allowed?('/users/new')

    assert_equal false, Lockdown::Delivery.allowed?('/users/create')

    assert_equal false, Lockdown::Delivery.allowed?('/users/destroy')
  end
end
