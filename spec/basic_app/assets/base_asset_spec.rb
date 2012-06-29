require 'spec_helper'

describe Repoman::BaseAsset  do

  describe 'self.path_to_name' do

    it "should replace one or more whitespace chars with a single underscore" do
      Repoman::BaseAsset.path_to_name("/path/to a/hello  world ").should == "hello_world"
    end

    it "should strip special chars # @ % * ' ! + . -" do
      Repoman::BaseAsset.path_to_name("/path/to a/.he@@llo' !w+orl-d'").should == "hello_world"
    end

    it "should replace '&' with '_and_'" do
      Repoman::BaseAsset.path_to_name("/path/to a/&hello &world&").should == "and_hello_and_world_and"
    end

    it "should lowercase the name" do
      Repoman::BaseAsset.path_to_name("d:/path/to a/Hello worlD").should == "hello_world"
    end

  end

  context "being created" do

    describe "name" do

      it "should be nil if unless name passed to initialize " do
        asset = Repoman::BaseAsset.new
        asset.name.should be_nil
      end

      it "should be the same as asset_name param " do
        asset = Repoman::BaseAsset.new("my_asset_name")
        asset.name.should == "my_asset_name"
      end

    end
  end

  describe 'attributes' do

    before :each do
      @asset = BasicApp::BaseAsset.new
      @asset.name = "test_asset"
    end

    describe 'description' do

      it "should be nil unless set" do
        @asset.attributes[:description].should be_nil
        @asset.description.should be_nil
      end

      it "should render mustache templates" do
        @asset.description = "This is a {{name}}"
        @asset.attributes[:description].should == "This is a {{name}}"
        @asset.description.should == "This is a test_asset"
      end

    end

    describe 'notes' do

      it "should be nil unless set" do
        @asset.attributes[:notes].should be_nil
        @asset.notes.should be_nil
      end

      it "should render mustache templates" do
        @asset.notes = "This is a {{name}}"
        @asset.attributes[:notes].should == "This is a {{name}}"
        @asset.notes.should == "This is a test_asset"
      end

    end

    describe 'path' do

      it "should be nil unless set" do
        @asset.attributes[:path].should be_nil
        @asset.path.should be_nil
      end

      it "should expand '~'" do
        @asset.path = "~/test/here"
        @asset.attributes[:path].should == "~/test/here"
        @asset.path.should_not match(/^#{File.expand_path(FileUtils.pwd)}\/test\/here$/)
        @asset.path.should match(/^\/.*\/test\/here$/)
      end

      it "should expand relative paths" do
        @asset.path = "test/here"
        @asset.attributes[:path].should == "test/here"
        @asset.path.should match(/^#{File.expand_path(FileUtils.pwd)}\/test\/here$/)
      end

      it "should render mustache templates" do
        @asset.path = "test/{{name}}/here"
        @asset.attributes[:path].should == "test/{{name}}/here"
        @asset.path.should match(/^#{File.expand_path(FileUtils.pwd)}\/test\/test_asset\/here$/)
      end

    end

    describe 'tags' do

      it "should be an empty array unless set" do
        @asset.attributes[:tags].should be_nil
        @asset.tags.should be_empty
      end

    end

  end
end

