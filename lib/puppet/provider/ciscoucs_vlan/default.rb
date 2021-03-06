require 'pathname'

provider_path = Pathname.new(__FILE__).parent.parent
Puppet.debug provider_path
require File.join(provider_path, 'ciscoucs')

#ucs_module = Puppet::Module.find('ciscoucs', Puppet[:environment].to_s)

Puppet::Type.type(:ciscoucs_vlan).provide(:default, :parent => Puppet::Provider::Ciscoucs) do

  include PuppetX::Puppetlabs::Transportciscoucs
  @doc = "Create VLAN on Cisco UCS device."
  def create
    formatter = PuppetX::Util::Ciscoucs::Xmlformatter.new("createvlan")
    parameters = PuppetX::Util::Ciscoucs::NestedHash.new
    parameters['/configConfMos/inConfigs/pair/fabricVlan'][:dn] = get_dn
    parameters['/configConfMos/inConfigs/pair'][:key] = get_dn
    parameters['/configConfMos/inConfigs/pair/fabricVlan'][:id] = @resource[:vlanid]
    parameters['/configConfMos/inConfigs/pair/fabricVlan'][:mcastPolicyName] = @resource[:mcast_policy_name]
    parameters['/configConfMos'][:cookie] = cookie
    parameters['/configConfMos/inConfigs/pair/fabricVlan'][:name] = @resource[:vlan_name]
    parameters['/configConfMos/inConfigs/pair/fabricVlan'][:sharing] = @resource[:sharing]
    parameters['/configConfMos/inConfigs/pair/fabricVlan'][:status] = @resource[:status]
    createvlanidxml = formatter.command_xml(parameters)
    ucscreatevlanidresp = post createvlanidxml
    disconnect
    createvlanidresponse = REXML::Document.new(ucscreatevlanidresp)
    root = createvlanidresponse.root
    createvlanidresponse.elements.each("/configConfMos/outConfigs/pair/fabricVlan") {
      |e|
      if e.attributes["status"].eql?('created')
        Puppet.debug "VLAN created successfully."
      end
    }

    if !root.attributes['errorDescr'].nil?
      raise Puppet::Error, root.attributes['errorDescr']
    end

  end

  def get_dn()
    dn = ""
    if @resource[:fabric_id].to_s.strip.length >0
      dn = "fabric/lan/#{@resource[:fabric_id]}/net-#{@resource[:vlan_name]}"
    else
      dn = "fabric/lan/net-#{@resource[:vlan_name]}"
    end
    return dn
  end

  def destroy
    Puppet.debug("destroy method call")
    formatter = PuppetX::Util::Ciscoucs::Xmlformatter.new("deletevlan")
    parameters = PuppetX::Util::Ciscoucs::NestedHash.new
    parameters['/configConfMos/inConfigs/pair/fabricVlan'][:dn] = get_dn
    parameters['/configConfMos/inConfigs/pair'][:key] = get_dn
    parameters['/configConfMos/inConfigs/pair/fabricVlan'][:id] = @resource[:vlanid]
    parameters['/configConfMos'][:cookie] = cookie
    parameters['/configConfMos/inConfigs/pair/fabricVlan'][:name] = @resource[:vlan_name]
    parameters['/configConfMos/inConfigs/pair/fabricVlan'][:status] = @resource[:status]
    createvlanidxml = formatter.command_xml(parameters)
    ucscreatevlanidresp = post createvlanidxml
    disconnect
    createvlanidresponse = REXML::Document.new(ucscreatevlanidresp)
    root = createvlanidresponse.root
    createvlanidresponse.elements.each("/configConfMos/outConfigs/pair/fabricVlan") {
      |e|
      if e.attributes["status"].eql?('deleted')
        Puppet.debug "VLAN id deleted successfully."
      end
    }
    if !root.attributes['errorDescr'].nil?
      raise Puppet::Error, root.attributes['errorDescr']
    end
  end

  def exists?
    if check_element_exists(get_dn)
      Puppet.debug "VLAN Name/Prefix : #{@resource[:vlan_name]} exist in UCS."
      return true
    else
      Puppet.debug "VLAN id does not exist."
      return false
    end
  end

end

