module Awsrm
  class Alb < Awsrm::Resource
    FILTER_MAP = {
      id: 'load_balancer_name',
      arn: 'load_balancer_arn',
      name: 'load_balancer_name',
      dns_name: 'dns_name',
      tags: ->(lb, value) { Alb.has_tags?(lb.load_balancer_arn, value) },
      vpc: ->(lb, value) { lb.vpc_id == Awsrm::Vpc.one(name: value).id }
    }.freeze

    class << self
      def all(params)
        lbs = elbv2_client.describe_load_balancers.map do |responce|
          responce.load_balancers
        end.flatten
        albs = lbs.select do |lb|
          lb.type == 'application'
        end
        albs.map do |lb|
          ret = params.all? do |key, value|
            raise UndefinedFilterParamError, key unless self::FILTER_MAP.key?(key)
            next self::FILTER_MAP[key].call(lb, value) if self::FILTER_MAP[key].is_a?(Proc)
            lb[self::FILTER_MAP[key]] == value
          end
          AlbReader.new(lb) if ret
        end.compact
      end

      def filters(_params)
        raise NoMethodError
      end

      def has_tags?(arn, tag_hash)
        tag_descriptions = elbv2_client.describe_tags(resource_arns: [arn]).tag_descriptions.flatten
        ret = tag_descriptions.find do |desc|
          desc.resource_arn == arn
        end
        return false if ret.nil?
        tag_hash.all? do |key, value|
          ret.tags.any? do |tag|
            tag.key == key.to_s && tag.value == value.to_s
          end
        end
      end
    end
  end

  class AlbReader < Awsrm::ResourceReader
    def id
      @resource.load_balancer_name
    end
  end
end
