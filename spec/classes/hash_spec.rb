require 'spec_helper'
require 'music/patches/hash'

describe Hash do
  describe '#flip' do
    it "Should reverse keys and values" do
      {1 => 2, 3 => 4}.flip.should == {2 => 1, 4 => 3}

      {'foo' => 'bar', 'baz' => 'bitz'}.flip.should == {'bitz' => 'baz', 'bar' => 'foo'}
    end

    it "Should return an empty hash from an empty hash" do
      {}.flip.should == {}
    end
  end

end
