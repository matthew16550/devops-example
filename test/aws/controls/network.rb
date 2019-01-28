title 'Network Checks'

vpc_id = ENV['VPC_ID']

control 'network-01' do
  title 'VPC'

  describe aws_vpc(vpc_id: vpc_id) do
    its ('state') { should cmp 'available' }
    its ('cidr_block') { should cmp '10.0.0.0/16' }
  end
end

control 'network-02' do
  title 'Subnets'

  describe aws_subnets.where(vpc_id: vpc_id) do
    its ('count') { should cmp 6 }
    its ('cidr_blocks') { should include '10.0.1.0/24' }
    its ('cidr_blocks') { should include '10.0.2.0/24' }
    its ('cidr_blocks') { should include '10.0.101.0/24' }
    its ('cidr_blocks') { should include '10.0.102.0/24' }
    its ('cidr_blocks') { should include '10.0.111.0/24' }
    its ('cidr_blocks') { should include '10.0.112.0/24' }
  end
end
