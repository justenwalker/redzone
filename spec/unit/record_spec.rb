require 'spec_helper'

describe RedZone::Record do
  it 'should default to IN class' do
    result = described_class.new({
      :name => 'name',
      :type => 'A',
      :data => '10.1.0.1'
    })
    result.to_s.should == "name                          IN    A        10.1.0.1            \n"
  end
  it 'should be commentable' do
    result = described_class.new({
      :name    => 'name',
      :type    => 'A',
      :data    => '10.1.0.1',
      :comment => 'Comment'
    })
    result.to_s.should == "name                          IN    A        10.1.0.1             ; Comment\n"
  end
  it 'should have a TTL' do
    result = described_class.new({
      :name    => 'name',
      :type    => 'A',
      :data    => '10.1.0.1',
      :ttl     => '1d'
    })
    result.to_s.should == "name                 86400    IN    A        10.1.0.1            \n"
  end
  it 'should quote TXT records' do
    result = described_class.new({
      :name    => 'name',
      :type    => 'TXT',
      :data    => 'hello there'
    })
    result.to_s.should == "name                          IN    TXT      \"hello there\"       \n"
  end
  it 'should collapse multi-line text records' do
    result = described_class.new({
      :name    => 'name',
      :type    => 'TXT',
      :data    => <<-eos
      Line1
      Line2
      Line3
      Line4
      eos
    })
    result.to_s.should == "name                          IN    TXT      \"Line1Line2Line3Line4\"\n"
  end
  it 'should require name option' do
    expect { described_class.new({:type => "A", :data => 'b'})}.to raise_error(ArgumentError,':name is required')
  end
  it 'should require type option' do
    expect { described_class.new({:name => "a", :data => 'b'})}.to raise_error(ArgumentError,':type is required')
  end
  it 'should require data option' do
    expect { described_class.new({:name => "a", :type => 'A'})}.to raise_error(ArgumentError,':data is required')
  end
end