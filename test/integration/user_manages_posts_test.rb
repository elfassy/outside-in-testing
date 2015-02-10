require 'test_helper'

class UserManagesPostsTest < ActionDispatch::IntegrationTest

  test "As a user, i want to create a blog post" do
    page = NewPostPage.new
    page.load

    new_post = {
      title: "Rails is great", 
      body: "Something clever"
    }
    page.submit_form(new_post)

    index_page = PostsPage.new
    assert_equal index_page.path, page.current_path 
    assert index_page.has_post?(new_post)
  end
end

class PageUI
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  def load
    visit path
  end
end

class PostsPage < PageUI
  def path
    posts_path
  end

  def has_post?(post)
    has_content?(post[:title])
  end
end

class NewPostPage < PageUI
  def path
    new_post_path
  end

  def submit_form(p)
    find("[name='post[title]']").set p[:title]
    find("[name='post[body]']").set p[:body]
    find("input[type='submit']").click
  end
end

