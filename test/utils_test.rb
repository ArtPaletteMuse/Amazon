require File.expand_path "../test_helper", __FILE__

context "ShowOff Utils tests" do
  setup do
  end

  #  create, init - Create new showoff presentation
  test "can initialize a new preso" do
    files = []
    in_temp_dir do
      ShowOffUtils.create('testing', true)
      files = Dir.glob('testing/**/*')
    end
    assert_equal ["testing/one", "testing/one/01_slide.md", "testing/showoff.json"], files
  end

  #  heroku       - Setup your presentation to serve on Heroku
  test "can herokuize" do
    files = []
    in_basic_dir do
      ShowOffUtils.heroku('test')
      files = Dir.glob('**/*')
      content = File.read('Gemfile')
      assert_match 'bluecloth', content
      assert_match 'nokogiri', content
      assert_match 'showoff', content
      assert_match 'gli', content
      assert_match 'heroku', content
    end
    assert files.include?('config.ru')
    assert files.include?('Gemfile')
  end

  test "can herokuize with password" do
    files = []
    in_basic_dir do
      ShowOffUtils.heroku('test', false, 'pwpw')
      content = File.read('config.ru')
      assert_match 'Rack::Auth::Basic', content
      assert_match 'pwpw', content
    end
  end

  #  static       - Generate static version of presentation
  test "can create a static version" do
  end

  #  github       - Puts your showoff presentation into a gh-pages branch
  test "can create a github version" do
  end

end
