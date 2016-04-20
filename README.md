# <a name="title"></a> Kitchen::PowerVC: A Test Kitchen Driver for PowerVC

A test kitchen Driver for PowerVC.

This driver uses the fog to provision and destroy nova instances. Use a PowerVC cloud for your infrastructure testing!

Shamelessly copied from [Fletcher Nichol](https://github.com/fnichol)'s awesome work on an [EC2 driver](https://github.com/test-kitchen/kitchen-ec2), and [Adam Leff](https://github.com/adamleff)'s amazing work on an [VRO driver](https://github.com/chef-partners/kitchen-vro).

Forked from Kitchen::Openstack created by Jonathan Hartman (<j@p4nt5.com>) and maintained by JJ Asghar (<jj@chef.io>)
Port for PowerVC support by Benoit Creau (<benoit.creau@chmod666.org>)

## Requirements

There are **no** external system requirements for this driver. However you will need access to an PowerVC cloud.

## Installation and Setup

Add this line to your application's Gemfile:

```ruby
gem 'kitchen-powervc'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install kitchen-powervc
```

Or if using [chefdk][chefdk_dl] install with:

```bash
$ chef gem install kitchen-powervc
```

## Minimum Configuration

```yaml
driver:
  name: openstack
  openstack_username: [YOUR OPENSTACK USERNAME]
  openstack_api_key: [YOUR OPENSTACK API KEY] # AKA your OpenStack Password
  openstack_auth_url: [YOUR OPENSTACK AUTH URL]
  require_chef_omnibus: [e.g. 'true' or a version number if you need Chef]
  image_ref: [SERVER IMAGE ID]
  flavor_ref: [SERVER FLAVOR ID]
transport:
  username: ubuntu # For a Ubuntu Box
```

The `image_ref` and `flavor_ref` options can be specified as an exact id,
an exact name, or as a regular expression matching the name of the image or flavor.

All of Fog's `openstack` options (`openstack_domain_name`, `openstack_project_name`,
...) are supported. This includes support for the OpenStack Identity v3 API.

## General Configuration

### name

**Required** Tell test-kitchen what driver to use. ;)

### openstack\_username

**Required** Your OpenStack username.

### openstack\_api\_key

**Required** Your OpenStack API Key, aka your OpenStack password.

### openstack\_auth\_url

**Required** Your OpenStack auth url.

### require\_chef_omnibus

**Required** Set to `true` otherwise the specific version of Chef omnibus you want installed.

### image\_ref

**Required** Server Image ID.

### flavor\_ref

**Required** Server Flavor ID.

### server\_name

If a `server_name_prefix` is specified then this prefix will be used when
generating random names of the form `<NAME PREFIX>-<RANDOM STRING>` e.g.
`myproject-asdfghjk`. If both `server_name_prefix` and `server_name` are
specified then the `server_name` takes precedence.

### server\_name\_prefix

If you want to have a static prefix for a random server name.

### private\_key\_path

The path to your private ssh key.

### public\_key\_path

The path to your public ssh key.

If a `key_name` is provided it will be used instead of any
`public_key_path` that is specified.

If a `key_name` is provided without any `private_key_path`, unexpected
behavior may result if your local RSA/DSA private key doesn't match that
OpenStack key. If you do key injection via `cloud-init` like this issue:
[#77](https://github.com/test-kitchen/kitchen-openstack/issues/77). The
`key_name` should be a blank string if you need to skip it. Example:

```yml
driver:
  [-- snip --]
  key_name: ""
  user_data: cloud_init
```

### port

Set the SSH port for the remote access.

### openstack\_tenant

Your OpenStack tenant id.

### openstack\_region

Your OpenStack region id.

### openstack\_service\_name

Your OpenStack compute service name.

### openstack\_network\_name

Your OpenStack network name used to connect to, if you have only private network
connections you want declare this.

### glance\_cache\_wait\_timeout
When OpenStack downloads the image into cache, it takes extra time to provision.  Timeout controls maximum amount of time to wait for machine to move from the Build/Spawn phase to Active.

### server\_wait

`server_wait` is a workaround to deal with how some VMs with `cloud-init`.
Some clouds need this some, most OpenStack instances don't. This is a stop gap
wait makes sure that the machine is in a good state to work with. Ideally the
transport layer in Test-Kitchen will have a more intelligent way to deal with this.
There will be a dot that appears every 10 seconds as the timer counts down.
You may want to add this for **WinRM** instances due to the multiple restarts that
happen on creation and boot. A good default is `300` seconds to make sure it's
in a good state.

The default is `0`.

### user\_data

If your vms have `cloud-init` enabled you can use the `user_data` in your
kitchen.yml to inject commands at boot time.

```
    driver_config:
      user_data: userdata.txt
```

Then create a `userdata.txt` in the same directory as your .kitchen.yml,
for example:

```
#!/bin/sh
echo "do whatever you want to pre-configure your machine"
```

### network\_ref

**Deprecated** A list of network names or ids to create instances with.

```yaml
network_ref:
   - [OPENSTACK NETWORK NAMES OR...]
   - [...ID TO CREATE INSTANCE WITH]
```

### fixed_ip

The ip that will be used by the instance, if not specified an ip will be automatically picked from the pool ip
```yaml
fixed_ip: [ipv4_ipaddress]
```

### no\_ssh\_tcp\_check

**Deprecated** You should be using transport now. This will skip the ssh check to automatically connect.

The default is `false`.

### no\_ssh\_tcp\_check\_sleep

**Deprecated** You should be using transport now. This will sleep for so many seconds. `no_ssh_tcp_check` needs
to be set to `true`.

## Disk Configuration

### <a name="config-block_device_mapping"></a> block\_device\_mapping

#### make\_volume

Makes a new volume when set to `true`.

The default is `false`.

#### snapshot\_id

When set, will make a volume from that snapshot id.

#### volume\_id

When set, will attach the volume id.

#### device\_name

Set this to `vda` unless you really know what you are doing.

#### availability\_zone

The block storage availability zone.

The default is `nova`.

#### volume\_type

The volume type, this is optional.

#### delete\_on\_termination

This will delete the volume on the instance when `destroy` happens, if set to true.
Otherwise set this to `false`.

#### creation\_timeout
Timeout to wait for volume to become available.  If a large volume is provisioned, it might take time to provision it on the backend.  Maximum amount of time to wait for volume to be created and be available.

#### Example

```yaml
block_device_mapping:
  make_volume: true
  snapshot_id: 00000-111111-0000222-000
  device_name: vda
  availability_zone: nova
  delete_on_termination: false
  creation_timeout: 120
```

## Network and Communication Configuration

### network\_ref

The `network_ref` option can be specified as an exact id, an exact name,
or as a regular expression matching the name of the network. You can pass one

```yaml
  network_ref: MYNET1
```

or many networks

```yaml
network_ref:
  - MYNET1
  - MYNET2
```

The `openstack_network_name` is used to select IP address for SSH connection.
It's recommended to specify this option in case of multiple networks used for
instance to provide more control over network connectivity.

Please note that `network_ref` relies on Network Services (`Fog::Network`) and
it can be unavailable in your OpenStack installation.

### fixed_ip

The ip that will be used by the instance, if not specified an ip will be automatically picked from the pool ip
```yaml
fixed_ip: [ipv4_ipaddress]
```

### disable\_ssl\_validation

```yaml
  disable_ssl_validation: true
```

Only disable SSL cert validation if you absolutely know what you are doing,
but are stuck with an OpenStack deployment without valid SSL certs.

## Example

The following could be used in a `.kitchen.yml` or in a `.kitchen.local.yml`
to override default configuration.

```yaml
---
driver:
  name: powervc
  openstack_username: [YOUR OPENSTACK USERNAME]
  openstack_api_key: [YOUR OPENSTACK API KEY] # AKA your OPENSTACK PASSWORD
  openstack_auth_url: [YOUR OPENSTACK AUTH URL]
  require_chef_omnibus: [e.g. 'true' or a version number if you need Chef]
  image_ref: [SERVER IMAGE ID]
  flavor_ref: [SERVER FLAVOR ID]

transport:
  ssh_key: /path/to/id_rsa  # probably the same as private_key_path
  connection_timeout: 10
  connection_retries: 5
  username: ubuntu
  password: mysecreatpassword

platforms:
  - name: ubuntu-14.04
  - name: ubuntu-15.04
  - name: centos-7
    transport:
      username: centos
  - name: windows-2012r2
    transport:
      password: myadministratorpassword

suites:
# ...
```

Another example working with PowerVc
```yaml
driver:
  name: powervc
  server_wait: 100
  openstack_username: "root"
  openstack_api_key: "root"
  openstack_auth_url: "https://powervchost/v3/auth/tokens"
  openstack_region: "RegionOne"
  openstack_project_domain: "Default"
  openstack_user_domain: "Default"
  openstack_project_name: "ibm-default"
  image_ref: "kitchen-aix72"
  flavor_ref: "mytemplate"
  server_name_prefix: "chefkitchen"
  network_ref: "testvlan"
  fixed_ip: "9.1.1.15"
  public_key_path: "/home/chef/.ssh/id_dsa.pub"
  private_key_path: "/home/chef/.ssh/id_dsa"
  username: "root"
  user_data: userdata.txt

provisioner:
  name: chef_solo
  chef_omnibus_url: "http://chefomnibus:8080/chefclient/install.sh"
  sudo: false

platforms:
  - name: aix72

suites:
  - name: aixcookbook
    run_list:
    - recipe[aix::root_authorized_keys]
    - recipe[aix::gem_source]
    attributes: { gem_source: { add_urls: [ "http://9.1.1.16:8808" ], delete_urls: [ "https://rubygems.org/" ] } }

busser:
  sudo: false
```

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the tests and rubocop, `bundle exec rake spec` and `bundle exec rake rubocop`
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## <a name="authors"></a> Authors

Created by Jonathan Hartman (<j@p4nt5.com>)
and maintained by JJ Asghar (<jj@chef.io>)
PowerVC port by Benoit Creau (<benoit.creau@chmod666.org>)

## <a name="license"></a> License

Apache 2.0

