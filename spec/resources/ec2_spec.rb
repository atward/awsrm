require 'spec_helper'

RSpec.describe Awsrm::Ec2 do
  before(:each) do
    require 'stub/ec2'
  end

  it '#one().id' do
    expect(Awsrm::Ec2.one(name: 'my-ec2').id).to eq 'i-ec12345a'
  end

  it '#filters' do
    expect(Awsrm::Ec2.filters(id: 'i-ec12345a')).to eq [{ name: 'instance-id', values: ['i-ec12345a'] }]
    expect(Awsrm::Ec2.filters(instance_id: 'i-ec12345a')).to eq [{ name: 'instance-id', values: ['i-ec12345a'] }]
    expect(Awsrm::Ec2.filters(name: 'my-ec2')).to eq [{ name: 'tag:Name', values: ['my-ec2'] }]
    expect(Awsrm::Ec2.filters(vpc_id: 'vpc-ab123cde')).to eq [{ name: 'vpc-id', values: ['vpc-ab123cde'] }]
    expect(Awsrm::Ec2.filters(vpc: 'my-vpc')).to eq [{ name: 'vpc-id', values: ['vpc-ab123cde'] }]
    expect(Awsrm::Ec2.filters(elb: 'my-elb')).to eq [{ name: 'instance-id',
                                                       values: ['i-ec12345a', 'i-ec789dsa'] }]
    expect(Awsrm::Ec2.filters(alb_target_group: 'my-alb-target-group')).to eq [{ name: 'instance-id',
                                                                                 values: ['i-0f76fade', 'i-ec12345a'] }]
  end

  it '#one().* access Aws::EC2::Types::Instance' do
    expect(Awsrm::Ec2.one(name: 'my-ec2').state.name).to eq 'running'
  end
end
