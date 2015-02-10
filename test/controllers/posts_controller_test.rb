require 'test_helper'

class PostsControllerTest < ActionController::TestCase

  test "create valid post" do
    p = posts(:one)
    assert_difference 'Post.count', +1 do
      post :create, post: {title: p.title, body: p.body }
    end
    new_post = Post.last
    assert_equal new_post.title, p.title
    assert_equal new_post.title, p.body
  end

  test "create invalid post" do
    p = posts(:one)
    assert_difference 'Post.count', 0 do
      post :create, post: {body: p.body }
    end
    assert_not_nil assigns(:post)
  end
end
