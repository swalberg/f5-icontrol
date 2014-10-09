require 'thor'

module F5
  module Cli
    class Pool < Thor

      desc "list", "Lists all the pools"
      def list
        response = client.LocalLB.Pool.get_list

        pools = Array(response[:item])
        if pools.empty?
          puts "No pools found"
        else
          pools.each do |p|
            puts p
          end
        end
      end

      desc "show POOL", "Shows a pool's status"
      def show(pool)
        members = pool_members(pool)
        if members.empty?
          puts "Pool #{pool} is empty"
        else
          members.each do |member|
            puts "#{member[:address]}:#{member[:port]}"
          end
        end
      end

      desc "status POOL", "Shows the status of a pool"
      def status(pool)
        members = pool_members(pool)
        response = client.LocalLB.Pool.get_member_object_status(
          pool_names: { item: [ pool ] },
          members: { item: [ members ] }
        )
        statuses = Array(response[:item][:item])
        puts "%20s %25s %25s" % ["Address", "Availability", "Enabled"]
        statuses.each_with_index do |s, idx|
          puts "%20s %25s %25s" % [ members[idx][:address], s[:availability_status].split(/_/).last, s[:enabled_status].split(/_/).last ]
        end
      end

      desc "enable POOL MEMBERS", "Enables the given members"
      def enable(pool, *members)
        set = pool_members(pool).select do |m|
          members.include? m[:address]
        end

        response = client.LocalLB.Pool.set_member_session_enabled_state(
          pool_names: { item: [ pool ] },
          members: { item: [ set ] },
          session_states: {  item: [ set.map { "STATE_ENABLED" } ] }
        )

      end

      desc "disable POOL MEMBERS", "Disables the given members"
      def disable(pool, *members)
        set = pool_members(pool).select do |m|
          members.include? m[:address]
        end

        response = client.LocalLB.Pool.set_member_session_enabled_state(
          pool_names: { item: [ pool ] },
          members: { item: [ set ] },
          session_states: {  item: [ set.map { "STATE_DISABLED" } ] }
        )
      end

      private

      def pool_members(pool)
        response = client.LocalLB.Pool.get_member_v2(pool_names: { item: [ pool ] } )
        members = Array(response[:item][:item])
        members.map { |m| { address: m[:address], port: m[:port] } }
      end

      def client
        @client || F5::Icontrol::API.new
      end

    end

    class Application < Thor
      desc 'hello', 'says hi'

      def hello(test)
        puts "hello #{test}"
      end

      desc "pool SUBCOMMAND ...ARGS", "manage pools"
      subcommand "pool", Pool

    end
  end
end
