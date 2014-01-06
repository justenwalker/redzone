require 'spec_helper'

describe RedZone::Arpa do
  let (:arpa_ipv4) {
    described_class.new({
      :name    => '32.12.in-addr.arpa',
      :network => '12.32.0.0/16',
      :soa => 'mock_soa'
    })      
  }
  let (:arpa_ipv6) { 
    described_class.new(
      :name => '9.8.7.6.4.3.2.1.1.0.0.2.ip6.arpa',
      :network => '2001:1234:6789::/48',
      :soa => 'mock_soa'
    )
  }
  context "ipv4 network" do
    subject { arpa_ipv4 }
    its(:name) { should == '32.12.in-addr.arpa'}
    its(:network) { should == IPAddr.new('12.32.0.0/16') }
  end
  context "ipv6 network" do
    subject { arpa_ipv6 }
    its (:name)    { should == '9.8.7.6.4.3.2.1.1.0.0.2.ip6.arpa' }
    its (:network) { should == IPAddr.new('2001:1234:6789::/48') }
  end
  it 'should require name option' do
    expect { described_class.new({:network => '12.32.0.0/16', :soa => 'soa'})}.to raise_error(ArgumentError,':name is required')
  end
  it 'should require network option' do
    expect { described_class.new({:name => '32.12.in-addr.arpa', :soa => 'soa'})}.to raise_error(ArgumentError,':network is required')
  end
  it 'should require soa option' do
    expect { described_class.new({:name => '32.12.in-addr.arpa', :network => '12.32.0.0/16' })}.to raise_error(ArgumentError,':soa is required')
  end
end