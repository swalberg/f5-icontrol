require 'thor'

module F5
  module Cli
    class Subcommand < Thor

      private

      def extract_items(response, opts = nil)
        items = response[:item]

        if items.nil?
          return opts == :as_array ? [] : nil
        end

        if items.is_a?(Hash) && items.has_key?(:item)
          items = items[:item]
        end
        if opts == :as_array && items.is_a?(Hash)
          [ items ]
        else
          items
        end
      end

      def client
        return @client if @client
        config = YAML.load_file(options[:config])
        if config.key?('username') && options[:lb] == 'default'
          puts "Warning: credentials in #{options[:config]} should be put under a named load balancer."
          configure_lb_as(config)
        else
          configure_lb_as config[options[:lb]]
        end
        F5::Icontrol::API.new
      end

      def configure_lb_as(config)
        F5::Icontrol.configure do |f5|
          f5.host = config['host']
          f5.username = config['username']
          f5.password = config['password']
        end
      end

      def itemize(option)
        {
          item: [ option ]
        }
      end

    end

    class Node < Subcommand
      desc "list", "Lists all the nodes"
      def list
        response = client.LocalLB.NodeAddressV2.get_list

        nodes = extract_items(response, :as_array)
        if nodes.empty?
          puts "No nodes found"
        else
          nodes.each do |node|
            puts node
          end
        end
      end

      desc "show NAME", "Shows information about a node"
      def show(node)
        session_status = extract_items client.LocalLB.NodeAddressV2.get_object_status(nodes: { item: [ node ] })
        stats = client.LocalLB.NodeAddressV2.get_statistics(nodes: { item: [ node ] })
        outer_envelope = extract_items stats[:statistics]
        stats = extract_items outer_envelope[:statistics]

        total_connections = stats.find { |stat| stat[:type] == "STATISTIC_SERVER_SIDE_CURRENT_CONNECTIONS" }
        total_connections = total_connections[:value][:low]

        puts "#{node} #{session_status[:availability_status]} (#{session_status[:status_description]}) with #{total_connections} connections"
      end

      desc "disable NAME", "Disables a particular node"
      def disable(node)
        client.LocalLB.NodeAddressV2.set_monitor_state(
          nodes: { item: [ node ] },
          states: { item: [ "STATE_DISABLED" ] }
        )
      end

      desc "enable NAME", "Enables a particular node"
      def enable(node)
        client.LocalLB.NodeAddressV2.set_monitor_state(
          nodes: { item: [ node ] },
          states: { item: [ "STATE_ENABLED" ] }
        )
      end


    end

    class SelfIP < Subcommand
      desc "list", "Lists all the self IPs"
      def list
        response = client.Networking.SelfIPV2.get_list

        selfips = extract_items(response, :as_array)
        if selfips.empty?
          puts "No selfips found"
        else
          selfips.each do |selfip|
            puts selfip
          end
        end
      end

      desc "show NAME", "Shows information about a self IP"
      def show(name)
        address = extract_items client.Networking.SelfIPV2.get_address(self_ips: { item: [ name ] })
        netmask = extract_items client.Networking.SelfIPV2.get_netmask(self_ips: { item: [ name ] })
        vlan = extract_items client.Networking.SelfIPV2.get_vlan(self_ips: { item: [ name ] })
        trafficgroup = extract_items client.Networking.SelfIPV2.get_traffic_group(self_ips: { item: [ name ] })
        floating = extract_items client.Networking.SelfIPV2.get_floating_state(self_ips: { item: [ name ] })

        puts "#{address}/#{netmask}"
        puts vlan
        puts "#{trafficgroup} #{floating == 'STATE_ENABLED' ? 'FLOATING' : 'NONFLOATING'}"
      end

      desc "create NAME IP/NETMASK VLAN", "Creates a self IP"
      option :floating, type: :boolean, default: false
      option :traffic_group, default: 'traffic-group-local-only'
      def create(name, address, vlan)
        (ip, netmask) = address.split(/\//)
        result = client.Networking.SelfIPV2.create(
          self_ips: itemize(name),
          vlan_names: itemize(vlan),
          addresses: itemize(ip),
          netmasks: itemize(netmask),
          traffic_groups: itemize(options[:traffic_group]),
          floating_states: itemize(options[:floating] ? 'STATE_ENABLED' : 'STATE_DISABLED')
        )
      end
    end

    class Interface < Subcommand

      desc "list", "Lists all the interfaces"
      def list
        response = client.Networking.Interfaces.get_list

        interfaces = extract_items(response, :as_array)
        if interfaces.empty?
          puts "No interfaces found"
        else
          interfaces.each do |interface|
            puts interface
          end
        end
      end
    end

    class VLAN < Subcommand

      desc "list", "Lists all the vlans"
      def list
        response = client.Networking.VLAN.get_list

        vlans = extract_items(response, :as_array)
        if vlans.empty?
          puts "No VLANs found"
        else
          vlans.each do |vlan|
            puts vlan
          end
        end
      end

      desc "show VLAN_NAME", "Show a particular vlan"
      def show(name)
        members = extract_items client.Networking.VLAN.get_member(vlans: { item: [ name ] } ), :as_array

        vid = extract_items client.Networking.VLAN.get_vlan_id(vlans: { item: [ name ] } )

        failsafe_state = extract_items client.Networking.VLAN.get_failsafe_state(vlans: { item: [ name ] } )

        puts "VLAN id #{vid} and failsafe is #{failsafe_state}"
        members.each do |member|
          puts "Interface %s is a %s and tag state is %s" % [ member[:member_name], member[:member_type], member[:tag_state] ]
        end
      end

      desc "create VLAN_ID VLAN_NAME member1type:member1name ", "Create a vlan with the name and ID, attached to the given members"
      def create(vid, name, *members)
        if members.empty?
          puts "I need at least one member interface"
          exit
        end

        memberdata = members.map do |m|
          (mtype, mname) = m.split /:/
          if mname.nil?
            puts "Each member must be in the form of interface/trunk:id"
            exit
          end
          { member_name: mname,
            member_type: (mtype == 'trunk' ? 'MEMBER_TRUNK' : 'MEMBER_INTERFACE'),
            tag_state: 'MEMBER_TAGGED' }
        end

        response = client.Networking.VLAN.create_v2(
          vlans: { item: [ name ] },
          vlan_ids: { item: [ vid ] },
          members: { item: [ item: memberdata ] },
          failsafe_states: { item: [ 'STATE_DISABLED' ] },
          timeouts: { item: [ 100 ] } #???
        )
        puts response

      end
    end

    class Pool < Subcommand

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
        statuses = response[:item][:item]
        statuses = [ statuses ] if statuses.is_a? Hash

        response = client.LocalLB.Pool.get_all_member_statistics(
          pool_names: { item: [ pool ] }
        )

        stats = response[:item][:statistics][:item]
        stats = [ stats ] if stats.is_a? Hash

        connections = stats.map do |host|
          stats = host[:statistics][:item]
          c = stats.find { |stat| stat[:type] == "STATISTIC_SERVER_SIDE_CURRENT_CONNECTIONS" }
          c[:value][:high].to_i * (2<<32) + c[:value][:low].to_i
        end

        puts "%20s %25s %25s %25s" % ["Address", "Availability", "Enabled", "Current Connections"]
        statuses.each_with_index do |s, idx|
          puts "%20s %25s %25s %25s" % [ members[idx][:address], s[:availability_status].split(/_/).last, s[:enabled_status].split(/_/).last, connections[idx]]
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
          session_states: { item: [ set.map { "STATE_ENABLED" } ] }
        )

        response = client.LocalLB.Pool.set_member_monitor_state(
          pool_names: { item: [ pool ] },
          members: { item: [ set ] },
          monitor_states: { item: [ set.map { "STATE_ENABLED" } ] }
        )

      end

      desc "disable POOL MEMBERS", "Disables the given members"
      method_option :force, default: false, type: :boolean, desc: "Forces the node offline (only active connections allowed)"
      def disable(pool, *members)
        set = pool_members(pool).select do |m|
          members.include? m[:address]
        end

        response = client.LocalLB.Pool.set_member_session_enabled_state(
          pool_names: { item: [ pool ] },
          members: { item: [ set ] },
          session_states: { item: [ set.map { "STATE_DISABLED" } ] }
        )

        if options[:force]
          response = client.LocalLB.Pool.set_member_monitor_state(
            pool_names: { item: [ pool ] },
            members: { item: [ set ] },
            monitor_states: { item: [ set.map { "STATE_DISABLED" } ] }
          )
        end
      end

      desc "setratio POOL MEMBERS", "Sets the ratio of the given members to RATIO"
      method_option :ratio, type: :numeric, desc: "The node's new ratio", required: true
      def setratio(pool, *members)
        set = address_port_list_from_pool(pool, members)
        response = client.LocalLB.Pool.set_member_ratio(
          pool_names: { item: [ pool ] },
          members: { item: [ set ] },
          ratios: { item: [ set.map { options[:ratio] } ] }
        )
      end

      desc "setconnections POOL MEMBERS", "Sets the connection limit on MEMBERS to LIMIT"
      method_option :limit, type: :numeric, desc: "The node's new connection limit", required: true
      def setconnections(pool, *members)
        set = address_port_list_from_pool(pool, members)
        response = client.LocalLB.Pool.set_member_connection_limit(
          pool_names: { item: [ pool ] },
          members: { item: [ set ] },
          limits: { item: [ set.map { options[:limit] } ] }
        )
      end

      private

      def address_port_list_from_pool(pool, members)
        pool_members(pool).select do |m|
          members.include?(m[:address]) || members.include?(m[:address].gsub(%r{^/Common/}, ''))
        end
      end

      def pool_members(pool)
        response = client.LocalLB.Pool.get_member_v2(pool_names: { item: [ pool ] } )

        members = response[:item][:item]
        members = [ members ] if members.is_a? Hash

        members.map { |m| { address: m[:address], port: m[:port] } }
      end

    end

    class Config < Subcommand
      desc "list", "Lists the current configuration variables."
      def list
        response = client.Management.DBVariable.get_list

        dbVariables = Array(response[:item])
        if dbVariables.empty?
          puts "No config variables found"
        else
          dbVariables.each do |p|
            puts "#{p[:name]}: #{p[:value]}"
          end
        end
      end
    end

    class Device < Subcommand
      desc "list", "Lists the all devices regardless of device group."
      def list
        response = client.Management.Device.get_list

        devices = Array(response[:item])
        if devices.empty?
          puts "No devices found"
        else
          devices.each do |p|
            puts p
          end
        end
      end
    end

    class DeviceGroup < Subcommand
      desc "list", "Lists the all device groups."
      def list
        response = client.Management.DeviceGroup.get_list

        devices = Array(response[:item])
        if devices.empty?
          puts "No devices found"
        else
          devices.each do |p|
            puts p
          end
        end
      end

      desc "status DEVICE_GROUP", "Shows the sync status between devices in the specified device group. (Shows status of all device groups of one is not specified.)"
      def status(device_group=nil)
        response = client.Management.DeviceGroup.get_sync_status(device_groups: { item: [ device_group ] })
        puts "STATUS: #{response[:item][:status]}";
        puts "STATUS COLOR: #{response[:item][:color]}";
        puts "STATUS DESCRIPTION: #{response[:item][:member_state]}";
        puts "STATUS SUMMARY: #{response[:item][:summary]}";
        puts "STATUS DETAILS:"
        puts response[:item][:details][:item].nil? ? "No further details." : response[:item][:details][:item]
      end

      desc "sync DEVICE_GROUP DEVICE_WITH_CHANGES_PENDING", "This will sync configs between devices in the specified device group."
      def sync(device_group, device)
        device = "#{device.gsub(%r{^/Common/}, '')}"
        response = client.System.ConfigSync.synchronize_to_group_v2(group: device_group, device: "/Common/#{device}", force: false)
        if response.nil? || response.empty?
          puts "Sync completed."
        else
          puts "Sync did not complete."
        end
      end
    end

    class Application < Thor
      class_option :lb, default: 'default'

      class_option :config, :type => :string, :default => "#{ENV['HOME']}/.f5.yml", :desc => "Defines the location of the configuration file."

      desc "node SUBCOMMAND ...ARGS", "manage nodes"
      subcommand "node", Node

      desc "pool SUBCOMMAND ...ARGS", "manage pools"
      subcommand "pool", Pool

      desc "interface SUBCOMMAND ...ARGS", "manage interfaces"
      subcommand "interface", Interface

      desc "selfip SUBCOMMAND ...ARGS", "manage self IPs"
      subcommand "selfip", SelfIP

      desc "vlan SUBCOMMAND ...ARGS", "manage vlans"
      subcommand "vlan", VLAN

      desc "config SUBCOMMAND ...ARGS", "view config values"
      subcommand "config", Config

      desc "device SUBCOMMAND ...ARGS", "manage devices"
      subcommand "device", Device

      desc "devicegroup SUBCOMMAND ...ARGS", "manage device groups"
      subcommand "devicegroup", DeviceGroup
    end
  end
end
