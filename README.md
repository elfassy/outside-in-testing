
#[fit] Outside-In agile testing

---

# Michael Elfassy
smashingboxes.com
@michaelelfassy

## We're hiring

![fit right](/Users/michaelelfassy/Dropbox/SB Canada/logo.png)

^ Welcome everyone
^ Introduction

---

> Every line of code is both an **asset** and a **liability**

^ also true for test code
^ asset: makes sure our app works
^ liability: Costs money to write, needs to be maintained modified over time. 

---

# Why do we write tests?

^ trust
^ expectations

---
# Goal
- Test all lines of code (aka 100% coverage)
- Test interactions between objects

^ Maintain tests up to date
^ code might be tested but if the messages being sent are wrong, it won't work
^ watch out for stubs and mocks (except for api calls)

---
# TDD
* Start by writing a test
* Red-Green refactor
* Work in small increments

^ Show of hands who uses TDD

---
# BDD
* Test the behavior of the system
* Outside-In 
* Focus on business goals

^ system here can be an object

---

# Benefits of Outside-In testing

* Emphasis on business goals (big picture)
* Leads to better design 
* Write only code you need
* Keep your tests DRY
* No need to add integrations once you are done

^ come back to it periodically while I’m coding
^ DHH - TDD causes design damage (excessive separation of concerns)
^ The feature helps me frame the problem properly, and focus on doing exactly what I need to make it work
^ usually end up writing and testing stuff on the model that I don’t ultimately need. 
^ Plus deep in the code, I lose track of the big picture.


---

# Demo!

```
> rails new blog
```

---

## Gems (today)
* Minitest 
* SimpleCov
* Capybara

^ Minitest is pre-configured with rails (bundled with ruby)

^ Gems I won’t be using (today)
^ Cucumber
^ Rspec
^ Factory Girl

---

# Integration tests
![](/Users/michaelelfassy/Desktop/maxresdefault.jpg)

---


# Feature
```
> rails g integration_test user_manages_posts
```
```ruby
class UserManagesPostsTest < ActionDispatch::IntegrationTest
#   Scenario: User adds a new post
#     Given I go to the new post page
#     And I fill in "Title" with "Rails is great"
#     And I fill in "Content" with "Something clever"
#     When I press "Create"
#     Then I should be on the post list page
#     And I should see "Rails is great"
end
```

^ consider cucumber or spinach
^ get from trello/pivotal tracker
^ build 'create' features first

---

## User story

```ruby
test "As a user, i want to create a blog post" do
  # Given I go to the new post page
  page = NewPostPage.new.load
end
```

---
# map a UI page to a class

* Readable DSL for tests
* Promotes Reuse
* Centralize UI coupling (One place to make changes)

---
# Page Object


```ruby
class NewPostPage
  include Capybara::DSL

  def load
    visit new_post_path
  end
end
```

> you can also use the SitePrism gem

---


## Missing route

```
NameError: undefined local variable or method `new_post_path'
...
```
--

```ruby
Rails.application.routes.draw do
  resources :posts
end
```

---
## Missing Controller

```
E

Error:
ActionController::RoutingError: uninitialized constant PostsController

1 tests, 0 assertions, 0 failures, 1 errors, 0 skips
```
--

```
> rails g controller posts
```
---
## Missing action


```
E

Error:
AbstractController::ActionNotFound: The action 'new' could not be found for PostsController

1 tests, 0 assertions, 0 failures, 1 errors, 0 skips
```

--

```ruby
class PostsController < ApplicationController
  def new
  end
end
```

```
> toutch app/views/posts/new.html.erb
```

---
## Back in the green


```
.

Finished tests in 3.092923s, 0.3233 tests/s, 0.0000 assertions/s.

1 tests, 0 assertions, 0 failures, 0 errors, 0 skips
```

---

#[fit] No need to test Rails

^ in this case, so far the controller

---

## Time to look back at our feature

```ruby
  test "As a user, i want to create a blog post" do
    # Given I go to the new post page
    # And I fill in "Title" with "Rails is great"
    # And I fill in "Body" with "Something clever"
    # When I press "Create"

    page = NewPostPage.new
    new_post = {
      title: "Rails is great", 
      body: "Something clever"
    }
    page.submit_form(new_post)
  end
```

---

```ruby
class PageUI
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  def load
    visit path
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
```

---

```ruby
test "As a user, i want to create a blog post" do
  page = NewPostPage.new
  page.load

  new_post = {
    title: "Rails is great", 
    body: "Something clever"
  }
  page.submit_form(new_post)

  # When I press "Create"
  # Then I should be on the post list page
  index_page = PostsPage.new
  assert_equal index_page.path, page.current_path 

  # And I should see "Rails is great"
  assert index_page.has_post?(new_post)
end
```

---

```ruby
class PostsPage < PageUI
  def path
    posts_path
  end

  def has_post?(post)
    has_content?(post[:title])
  end
end
```
---
```ruby
<%= form_for @post do |f| %>
    <%= f.label :title %>
    <%= f.text_field :title %>
    <%= f.label :body %>
    <%= f.text_area :body %>
    <%= f.submit "Create" %>
<% end %>
```

---

```
ActionView::Template::Error: First argument in form cannot contain nil or be empty
```

```
> rails g model post title body
```

- No need to test Rails (so no need to thest the post model yet)

---

```ruby
  def new
    @post = Post.new
  end
```


```
.

Finished tests in 0.529192s, 1.8897 tests/s, 5.6690 assertions/s.

1 tests, 3 assertions, 0 failures, 0 errors, 0 skips
```

---
## What were we building again?


^ Always going back to the business goal is useful

---

```
E

Finished tests in 0.665696s, 1.5022 tests/s, 4.5066 assertions/s.

Error:
UserManagesPostsTest#test_As_a_user,_i_want_to_create_a_blog_post:
AbstractController::ActionNotFound: The action 'create' could not be found for PostsController
    test/integration/user_manages_posts_test.rb:25:in `block in <class:UserManagesPostsTest>'

1 tests, 3 assertions, 0 failures, 1 errors, 0 skips
```

---
```ruby
  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to posts_path
    else
      render :new
    end
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
```
---

```
E

Finished tests in 26.022614s, 0.0384 tests/s, 0.1921 assertions/s.

Error:
UserManagesPostsTest#test_As_a_user,_i_want_to_create_a_blog_post:
AbstractController::ActionNotFound: The action 'index' could not be found for PostsController
    test/integration/user_manages_posts_test.rb:29:in `block in <class:UserManagesPostsTest>'

1 tests, 5 assertions, 0 failures, 1 errors, 0 skips
Coverage report generated for MiniTest to blog/coverage. 12 / 13 LOC (92.31%) covered.
```

---


#[fit] But wait! 

We have a conditional in our controller. 

```
Coverage report generated for MiniTest to blog/coverage. 12 / 13 LOC (92.31%) covered.
```

^ When using outside-in it's important to keep coverage at 100% before moving to the next failing test

---

![fit](/Users/michaelelfassy/Desktop/Screen Shot 2015-02-08 at 12.45.53 AM.png)

^ we're also not checking if the permitted attributes are correct!

---

```ruby
class PostsControllerTest < ActionController::TestCase

  test "create valid post" do
    p = posts(:valid)
    assert_difference 'Post.count', +1 do
      post :create, post: {title: p.title, body: p.body }
    end
    new_post = Post.last
    assert_equal new_post.title, p.title
    assert_equal new_post.title, p.body
  end

  # test "create invalid post" do
  #  p = posts(:invalid)
  #  assert_difference 'Post.count', 0 do
  #    post :create, post: {body: p.body }
  #  end
  #  assert_not_nil assigns(:post)
  # end
end
```
It might be worth considering a `service`, `interactor` or `mutation` object

---

```ruby
  test "As a user, i want to create a blog post" do
    # Given I go to the new post page
    get new_post_path

    # And I fill in "Title" with "Rails is great"
    # And I fill in "Body" with "Something clever"
    assert_select ":match('name', ?)", /.+\[title\]$/ 
    assert_select ":match('name', ?)", /.+\[body\]$/ 

    # When I press "Create"
    assert_select "input[type=submit]"

    # Then I should be on the post list page
    p = posts(:one)
    assert_difference 'Post.count', +1 do
      post posts_path, post: {title: p.title, body: p.body}
    end
    assert_response :redirect
    follow_redirect!

    # And I should see "Rails is great"
    assert_select ".post_title", p.title
  end
```

---

```
  def index
  end
```

```
Minitest::Assertion: Expected at least 1 element matching ".post_title", found 0..
```



---

## View


```
<% @posts.each do |post| %>
 <div class="post">
    <div class="post_title">
      <%= post.title %>
    </div>
  </div>
<% end %>
```

```
ActionView::Template::Error: undefined method `each' for nil:NilClass
```



---

## Controller

```
  def index
    @posts = Post.all
  end
```


---

```
...

Finished tests in 0.544110s, 5.5136 tests/s, 20.2165 assertions/s.

3 tests, 11 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to blog/coverage. 16 / 16 LOC (100.0%) covered.
```

---

## Outside-In led me to
- Keep focus on business goals
- Always have 100% coverage
- Have test code that is easier to maintain
- Made TDD more fun

