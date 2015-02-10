class PostsController < ApplicationController
  def new
    @post = Post.new
  end

  def index
    @posts = Post.all
  end

  def create
    @post = Post.new(params.require(:post).permit(:title, :body))
    if @post.save
      redirect_to posts_path
    else
      render :new
    end
  end
end
