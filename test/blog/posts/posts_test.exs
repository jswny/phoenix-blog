defmodule Blog.PostsTest do
  use Blog.DataCase
  import Blog.PostsFixtures
  alias Blog.Posts
  alias Blog.Posts.Post

  @valid_attrs post_valid_attrs()
  @invalid_attrs post_invalid_attrs()

  test "list_posts/0 lists all posts in order of insertion date" do
    posts = gen_post_fixtures(4)
    assert Posts.list_posts() == posts
  end

  test "list_published_posts/0 lists all published posts in order of insertion date" do
    posts = gen_post_fixtures(4)

    result = Posts.list_published_posts()
    published = Enum.filter(posts, fn p -> p.published == true end)
    unpublished = Enum.filter(posts, fn p -> p.published == false end)

    assert Posts.list_published_posts() == published

    for post <- unpublished do
      refute Enum.any?(result, fn p -> p.title == post.title end) == true
    end
  end

  describe "get_post_by_slug!/1" do
    test "returns the post with given slug" do
      post = post_fixture()
      assert Posts.get_post_by_slug!(post.slug) == post
    end

    test "raises Ecto.NoResultsError on invalid slug" do
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post_by_slug!("bad") end
    end
  end

  describe "create_post/1" do
    test "with valid data creates a post" do
      assert {:ok, %Post{} = post} = Posts.create_post(@valid_attrs)
      assert post.title == @valid_attrs.title
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "with valid data creates posts with valid slugs" do
      attrs_list = [
        %{title: "test post", body: "this is a test post.", published: true},
        %{title: "a@test$^post", body: "this is a test post.", published: true},
        %{title: "*()@test%123", body: "this is a test post.", published: true},
        %{title: "123test_post%^&*", body: "this is a test post.", published: true}
      ]

      for attrs <- attrs_list do
        {:ok, %Post{} = new_post} = Posts.create_post(attrs)
        assert new_post.slug == Slugger.slugify_downcase(attrs.title)
      end
    end

    test "converts unique_constraint on slug to error" do
      post_fixture(%{title: "a cool post", body: "this is a cool post.", published: true})
      attrs = Map.put(@valid_attrs, :title, "a cool post")
      assert {:error, %Ecto.Changeset{} = changeset} = Posts.create_post(attrs)
      assert {:slug, {"There was a problem generating a unique slug for this post. Please ensure that this title is not already taken.", []}} in changeset.errors
    end
  end

  describe "update_post/2" do
    @update_attrs %{title: "updated title"}

    setup do
      {:ok, post: post_fixture()}
    end

    test "with valid data updates the post", %{post: post} do
      assert {:ok, post} = Posts.update_post(post, @update_attrs)
      assert %Post{} = post
      assert post.title == @update_attrs.title
    end

    test "with invalid data returns error changeset", %{post: post} do
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post_by_slug!(post.slug)
    end

    test "with valid data updates posts with valid slugs", %{post: post} do
      attrs_list = [
        %{title: "test post"},
        %{title: "a@test$^post"},
        %{title: "*()@test%123"},
        %{title: "123test_post%^&*"}
      ]

      for attrs <- attrs_list do
        {:ok, updated_post} = Posts.update_post(post, attrs)
        assert %Post{} = updated_post
        assert updated_post.slug == Slugger.slugify_downcase(attrs.title)
      end
    end

    test "converts unique_constraint on slug to error", %{post: post} do
      new_post = post_fixture(%{title: "a cool post"})
      assert {:error, %Ecto.Changeset{} = changeset} = Posts.update_post(new_post, %{title: post.title})
      assert {:slug, {"There was a problem generating a unique slug for this post. Please ensure that this title is not already taken.", []}} in changeset.errors
    end
  end

  test "delete_post/1 deletes the post" do
    post = post_fixture()
    assert {:ok, %Post{}} = Posts.delete_post(post)
    assert_raise Ecto.NoResultsError, fn -> Posts.get_post_by_slug!(post.slug) end
  end

  test "change_post/1 returns a post changeset" do
    post = post_fixture()
    assert %Ecto.Changeset{} = Posts.change_post(post)
  end
end
